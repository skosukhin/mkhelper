import os
import re

import common


class Preprocessor:
    _re_ifdef = re.compile(r'^#\s*if(n)?def\s+([a-zA-Z_]\w*)')
    _re_if_expr = re.compile(r'^#\s*if((?:\s|\().*)')

    _re_elif = re.compile(r'^#\s*elif((?:\s|\().*)')
    _re_else = re.compile(r'^#\s*else(?:\s.*)')
    _re_endif = re.compile(r'^#\s*endif(?:\s.*)')

    _re_include = re.compile(r'^#\s*include\s+(?:"(.*?)"|<(.*?)>)')
    _re_define = re.compile(r'^#\s*define\s+([a-zA-Z_]\w*)(\(.*\))?\s+(.*)$')
    _re_undef = re.compile(r'^#\s*undef\s+([a-zA-Z_]\w*)')

    _re_cmd_line_define = re.compile(r'^=*([a-zA-Z_]\w*)(\(.*\))?(?:=(.+))?$')

    # matches "defined MACRO_NAME" and "defined (MACRO_NAME)"
    _re_defined_call = re.compile(
        r'(defined\s*(\(\s*)?([a-zA-Z_]\w*)(?(2)\s*\)))')

    _re_identifier = re.compile(
        r'(([a-zA-Z_]\w*)(\s*\(\s*(\w+(?:\s*,\s*\w+)*)?\s*\))?)')

    def __init__(self, stream, processed_file_dir, keep_debug_info=False):
        # input properties
        self.inc_order = []
        self.inc_root = ''
        self.inc_flag_dirs = []
        self.try_eval_expr = False

        # output properties
        self.included_files = set()
        self.if_expressions = []

        # private members
        self._keep_debug_info = keep_debug_info
        self._processed_file_dir = processed_file_dir
        self._include_reader = common.IncludeReader()
        self._include_reader.include(stream)

        self._defined_macros = {}

        # Stack of #if-#else blocks holds one of the following:
        # 1 - keep current branch and ignore another
        # -1 - ignore current branch and keep another
        # 0 - keep both branches (if failed to evaluate expression)
        self._if_state_stack = []

        # Each #elif is interpreted as a combination of #else and #if.
        # Thus, each #elif increments the number of #if blocks that are
        # closed with #endif statement. This numbers are stored in a separate
        # stack:
        self._states_per_endif_stack = []

    def readline(self):
        while True:
            line = self._include_reader.readline()
            if not line:
                return line

            if line.startswith('#'):
                # line continuation
                while line.endswith('\\\n'):
                    suffix = self._include_reader.readline()
                    line = line[:-2] + suffix

                # delete comments inside macro strings
                line = re.sub(r'/\*.*?\*/', '', line)

            # if(n)def statement
            match = Preprocessor._re_ifdef.match(line)
            if match:
                state = 0
                eval_expr = not self._check_ignore_branch()
                if eval_expr:
                    state = self._evaluate_def_to_state(match.group(2),
                                                        bool(match.group(1)))

                self._if_state_stack.append(state)
                self._states_per_endif_stack.append(1)

                self._log_result_for_debug(line, state, eval_expr)
                continue

            # if statement
            match = Preprocessor._re_if_expr.match(line)
            if match:
                state = 0
                eval_expr = (not self._check_ignore_branch() and
                             self.try_eval_expr)
                if eval_expr:
                    state = self._evaluate_expr_to_state(match.group(1))

                self._if_state_stack.append(state)
                self._states_per_endif_stack.append(1)

                self._log_result_for_debug(line, state, eval_expr)
                continue

            # elif statement
            match = Preprocessor._re_elif.match(line)
            if match:
                self._else()

                state = 0
                eval_expr = (not self._check_ignore_branch() and
                             self.try_eval_expr)
                if eval_expr:
                    state = self._evaluate_expr_to_state(match.group(1))

                self._if_state_stack.append(state)
                self._states_per_endif_stack[-1] += 1

                self._log_result_for_debug(line, state, eval_expr)
                continue

            # else statement
            match = Preprocessor._re_else.match(line)
            if match:
                self._else()
                continue

            # endif statement
            match = Preprocessor._re_endif.match(line)
            if match:
                if self._if_state_stack:
                    pop_count = self._states_per_endif_stack.pop()
                    for _ in range(pop_count):
                        self._if_state_stack.pop()
                continue

            if self._check_ignore_branch():
                continue

            # include statement
            match = Preprocessor._re_include.match(line)
            if match:
                self._include(match.group(match.lastindex))
                continue

            # define statement
            match = Preprocessor._re_define.match(line)
            if match:
                self._define(*match.group(1, 2, 3))
                continue

            # undef statement
            match = Preprocessor._re_undef.match(line)
            if match:
                self.undef(match.group(1))
                continue

            return line

    def close(self):
        self._include_reader.close()

    @property
    def name(self):
        return self._include_reader.name

    def define_from_cmd_line(self, macro_def):
        match = Preprocessor._re_cmd_line_define.match(macro_def)
        if match:
            name, args = match.group(1, 2)
            body = match.group(3) if match.group(3) else '1'
            self._define(name, args, body)

    def _define(self, name, args=None, body=None):
        if name != 'defined':
            self._defined_macros[name] = (args, '' if body is None else body)

    def undef(self, name):
        self._defined_macros.pop(name, None)

    def _include(self, file_path):
        inc_file = common.find_included_file(
            file_path,
            self.inc_order,
            self._processed_file_dir,
            os.path.dirname(self._include_reader.name),
            self.inc_flag_dirs)

        if inc_file and os.path.abspath(inc_file).startswith(self.inc_root):
            self._include_reader.include(open(inc_file, 'r'))
            self.included_files.add(inc_file)

    def _else(self):
        if self._if_state_stack:
            self._if_state_stack[-1] = -self._if_state_stack[-1]

    def _check_ignore_branch(self):
        return any(state < 0 for state in self._if_state_stack)

    def _log_result_for_debug(self, line, state, if_evaluated):
        if self._keep_debug_info:
            result = 'unknown'
            if not if_evaluated:
                result = 'suppressed'
            elif state == 1:
                result = 'true'
            elif state == -1:
                result = 'false'
            self.if_expressions.append((line, result))

    def _evaluate_def_to_state(self, macro, negate):
        return 1 if bool(macro in self._defined_macros) ^ negate else -1

    def _evaluate_expr_to_state(self, expr):
        prev_expr = expr
        while True:
            # replace calls to function "defined"
            defined_calls = re.findall(Preprocessor._re_defined_call, expr)
            for call in defined_calls:
                expr = expr.replace(
                    call[0], '1' if call[2] in self._defined_macros else '0')

            identifiers = re.findall(Preprocessor._re_identifier, expr)

            for ident in identifiers:
                if ident[1] == 'defined':
                    return 0

                macro = self._defined_macros.get(ident[1], None)
                if ident[2]:
                    # potential call to a function
                    if macro is None:
                        # call to undefined function
                        return 0
                    elif macro[0] is not None:
                        # we can't evaluate function-like macros
                        return 0
                    else:
                        # identifier is defined as object-like macro
                        expr = expr.replace(ident[0], macro[1] + ident[2])
                else:
                    # no function call
                    if macro is None or macro[0] is not None:
                        # macro is not defined or
                        # defined as function-like macro
                        expr = expr.replace(ident[0], '0')
                    else:
                        # identifier is defined as object-like macro
                        expr = expr.replace(ident[0], macro[1])

            if prev_expr == expr:
                break
            else:
                prev_expr = expr

        expr = expr.replace('||', ' or ')
        expr = expr.replace('&&', ' and ')
        expr = expr.replace('!', 'not ')

        try:
            result = bool(eval(expr, {}))
            return 1 if result else -1
        except:
            return 0
