import re

from depgen.include_reader import IncludeReader


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

    _re_block_comments_init = re.compile(r'(?:("|\').*?(?<!\\)\1)|(/\*)',
                                         re.DOTALL)

    def __init__(self, stream, **kwargs):
        self._include_reader = IncludeReader(stream)
        self._include_reader.include_root = kwargs.get('include_root', None)
        self._include_reader.include_dirs = kwargs.get('include_dirs', None)
        self._include_reader.include_order = kwargs.get('include_order', None)
        self._try_eval_expr = kwargs.get('try_eval_expr', False)
        self._enable_debug = kwargs.get('debug', False)

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

        self._if_expressions = [] if self._enable_debug else None

    def readline(self):
        while True:
            line = self._include_reader.readline()
            if not line:
                return line

            line = self._replace_continuation(line)
            if not line:
                return line

            line = self._remove_block_comments(line)
            if not line:
                return line

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
                             self._try_eval_expr)
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
                             self._try_eval_expr)
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
                self._include_reader.include(match.group(match.lastindex))
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

    @property
    def included_files(self):
        return self._include_reader.included_files

    def print_debug(self, stream):
        lines = [
            '# Preprocessor:\n'
            '#   Input file: ', self.name, '\n',
            '#   Conditional preprocessor statements:\n']

        if self._enable_debug:
            if self._if_expressions:
                lines.extend([
                    '#     ',
                    '\n#     '.join(
                        [expr[:-1] + ' = ' + result
                         for expr, result in self._if_expressions]), '\n'])
            else:
                lines.append('#     none\n')
        else:
            lines.append('#     debug info disabled\n')

        lines.append('#   Included files ("#include" directive):\n')
        if self._include_reader.included_files:
            lines.extend(['#     ',
                          '\n#     '.join(self.included_files),
                          '\n'])
        else:
            lines.append('#     none')

        stream.writelines(lines)

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

    def _else(self):
        if self._if_state_stack:
            self._if_state_stack[-1] = -self._if_state_stack[-1]

    def _check_ignore_branch(self):
        return any(state < 0 for state in self._if_state_stack)

    def _log_result_for_debug(self, line, state, if_evaluated):
        if self._enable_debug:
            result = 'unknown'
            if not if_evaluated:
                result = 'suppressed'
            elif state == 1:
                result = 'true'
            elif state == -1:
                result = 'false'
            self._if_expressions.append((line, result))

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

    def _replace_continuation(self, line):
        while line.endswith('\\\n'):
            suffix = self._include_reader.readline()
            line = line[:-2] + suffix
        return line

    def _remove_block_comments(self, line):
        rescan = True
        while rescan:
            rescan = False
            for match_init in \
                    Preprocessor._re_block_comments_init.finditer(line):
                # Check whether the line contains an unquoted block comment
                # initiator '/*':
                if match_init.group(2):
                    # Check whether the line contains a block comment
                    # terminator '*/' (even if it is quoted):
                    term_idx = line.find('*/', match_init.regs[2][1])
                    while term_idx < 0:
                        # The block is not terminated yet, read the next line:
                        next_line = self._include_reader.readline()
                        if not next_line:
                            # We have an unterminated block,
                            # return an empty line:
                            line = ''
                            break  # while term_idx < 0
                        line += next_line
                        term_idx = line.find('*/', match_init.regs[2][1])
                    else:
                        # Replace the block of comments with a single
                        # space:
                        line = line[:match_init.regs[2][0]] + \
                               ' ' + line[term_idx + 2:]
                        # We have removed the first block of comments,
                        # check if there is more on the next iteration:
                        rescan = True
                        break  # for match_init in ...
        return line
