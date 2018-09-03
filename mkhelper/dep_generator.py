import os
import argparse
import re
import sys


def get_args():
    parser = argparse.ArgumentParser(
        description='Generates OUTPUT makefile containing dependencies of the '
                    'INPUT Fortran source file. Recognizes Fortran "include", '
                    '"use" and "module" statements, as well as preprocessor '
                    '"#include", "#if" and associated directives. Optionally '
                    'evaluates simple expressions used in "#if" and "#elif" '
                    'directives.')
    parser.add_argument('input',
                        metavar='INPUT',
                        help='input Fortran source file')
    parser.add_argument('output',
                        metavar='OUTPUT',
                        help='output makefile with detected dependencies')
    parser.add_argument('--compile-target',
                        help='target of the compilation rule as it will '
                             'appear in the generated makefile; normally '
                             'equals to the path to the object file that is '
                             'supposed to be generated as a result of '
                             'compilation (by default, equals to name of the '
                             'INPUT without directory prefix and with '
                             'extension replaced with ".o" by default)')
    parser.add_argument('--compile-src-prereq',
                        help='source file prerequisite of the compilation '
                             'rule as it will appear in the generated '
                             'makefile; normally (and by default) equals to '
                             'INPUT but, for example, can be set to all but '
                             'the directory-part of the INPUT if vpath '
                             'feature is used')
    parser.add_argument('--mod-file-ext',
                        default='mod',
                        help='filename extension (without leading dot) of '
                             'compiler-generated Fortran module files '
                             '(default: %(default)s)')
    parser.add_argument('--mod-file-upper',
                        choices=['yes', 'no'], default='no',
                        help='whether Fortran compiler-generated module files '
                             'have uppercase names (default: %(default)s)')
    parser.add_argument('--inc-order',
                        default='src,flg', metavar='ORDER_LIST',
                        help='directory search order of files included using '
                             'the Fortran "include" statement; ORDER_LIST is '
                             'an ordered comma-separated list of keywords, '
                             'the corresponding search paths of which are to '
                             'be searched in the given order. The recognized '
                             'keywords are: "cwd" (for the current working '
                             'directory), "flg" (for directories '
                             'specified with -I compiler flag), "src" (for '
                             'the directory containing the INPUT source '
                             'file), and "inc" (for the directory containing '
                             'the file with the Fortran "include" statement. '
                             '(default: %(default)s)')
    parser.add_argument('--inc-pp-order',
                        default='inc,flg', metavar='ORDER_LIST',
                        help='equivalent to the "--inc-order" option, '
                             'only for the preprocessor "#include" directive. '
                             '(default: %(default)s)')
    parser.add_argument('--inc-root',
                        default='', metavar='INC_ROOT',
                        help='add to OUTPUT only "include"/"#include" '
                             'dependencies found inside INC_ROOT and its '
                             'subdirectories; does not affect Fortran '
                             '"module"/"use" dependencies')
    parser.add_argument('--try-eval-pp-expr',
                        action='store_true',
                        help='enable evaluation of expressions that appear in '
                             'preprocessor directives "#if" and "#elif"; if '
                             'disabled (default) or evaluation fails, both '
                             'branches of the directives are included by the '
                             'preprocessing stage.')
    parser.add_argument('--external-mods',
                        default='',
                        help='comma-separated list of modules to be'
                             'ignored when creating a dependency file')
    parser.add_argument('--fc-def-flag',
                        metavar='FC_DEF_FLAG', default='-D',
                        help='compiler flag used for preprocessor macro '
                             'definition; only flags starting with a single '
                             'dash (-) are currently supported (default: '
                             '%(default)s)')
    parser.add_argument('--fc-mod-out-flag',
                        metavar='FC_MOD_OUT_FLAG', default='-J',
                        help='compiler flag used to specify the directory '
                             'where module files are saved; only flags '
                             'starting with a single dash (-) are currently '
                             'supported (default: %(default)s)')
    parser.add_argument('--debug',
                        action='store_true',
                        help='dump debug information to file OUTPUT.debug')
    parser.add_argument('sep',
                        metavar='-- $(FCFLAGS)',
                        help='actual flags to be used in compilation, i.e. '
                             '$(FFLAGS) or $(FCFLAGS), must be given at the '
                             'end of the command line following the double '
                             'dash separator (--); the program searches these '
                             'flags for (possibly multiple instances of) '
                             'FC_DEF_FLAG, FC_MOD_OUT_FLAG and -I; any values '
                             'found are used in the generation of OUTPUT (in '
                             'the case of FC_MOD_OUT_FLAG, only the last '
                             'value found is used.')

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    arg_list = sys.argv[1:]

    # Separate arguments of this program and Fortran compiler flags
    sep = '--'
    if sep in arg_list:
        s = arg_list.index(sep)
        fortdep_arg_list = arg_list[:s]
        compiler_arg_list = arg_list[s + 1:]
    else:
        fortdep_arg_list = arg_list
        compiler_arg_list = []

    # append empty argument to keep argparse happy
    # about the positional argument sep
    args = parser.parse_args(fortdep_arg_list + [''])

    if args.compile_target is None:
        args.compile_target = os.path.splitext(
            os.path.basename(args.input))[0] + '.o'

    if args.compile_src_prereq is None:
        args.compile_src_prereq = args.input

    args.mod_file_upper = args.mod_file_upper == 'yes'

    args.inc_order = [c for c in args.inc_order.lower().split(',') if c]
    args.inc_pp_order = [c for c in args.inc_pp_order.lower().split(',') if c]

    if args.inc_root:
        args.inc_root = os.path.abspath(args.inc_root)

    args.external_mods = set(
        [c for c in args.external_mods.lower().split(',') if c])

    # Split multichar fc-flags from their value
    # (e.g. '-Wp,DMACRO' -> ['-Wp,D', 'MACRO']),
    # so argparse would understand them.
    known_flags = set([args.fc_mod_out_flag, args.fc_def_flag])
    compiler_arg_list_buf = []
    for arg in compiler_arg_list:
        for flag in known_flags:
            if arg.startswith(flag) and arg != flag:
                compiler_arg_list_buf.append(flag)
                arg = arg[len(flag):]
                break
        compiler_arg_list_buf.append(arg)

    compiler_parser = argparse.ArgumentParser()
    compiler_parser.add_argument('-I', default=[],
                                 action='append', dest='inc_dirs')
    compiler_parser.add_argument(args.fc_mod_out_flag, default='.',
                                 action='store', dest='mod_out_dir')
    compiler_parser.add_argument(args.fc_def_flag, default=[],
                                 action='append', dest='macro_defs')

    compiler_parser.parse_known_args(compiler_arg_list_buf, namespace=args)

    return args


def find_included_file(filename, inc_order, src_dir, inc_dir, flag_dirs):
    if os.path.isabs(filename):
        if os.path.isfile(filename):
            return os.path.normpath(filename)
    else:
        dir_list = []
        for inc_id in inc_order:
            if inc_id == 'cwd':
                dir_list.append('.')
            elif inc_id == 'flg':
                dir_list.extend(flag_dirs)
            elif inc_id == 'src':
                dir_list.append(src_dir)
            elif inc_id == 'inc':
                dir_list.append(inc_dir)
            else:
                continue

        for d in dir_list:
            result = os.path.join(d, filename)
            if os.path.isfile(result):
                return os.path.normpath(result)
    return None


class ContiguousIncludeReader:
    def __init__(self):
        # Stack of tuples of file-like objects and paths to the directories
        # where they reside. File-like objects must have readline() and
        # close() methods.
        self._file_stack = []

        # output property
        self.current_file_dir = None

    def readline(self):
        while self._file_stack:
            stream, self.current_file_dir = self._file_stack[-1]
            line = stream.readline()
            if line:
                return line
            else:
                self._file_stack.pop()[0].close()
        return ''

    def close(self):
        for stream, _ in self._file_stack:
            stream.close()
        self._file_stack = []

    def include(self, stream, file_dir):
        self._file_stack.append((stream, file_dir))


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
        self._include_reader = ContiguousIncludeReader()
        self._include_reader.include(stream, processed_file_dir)

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
        inc_file = find_included_file(file_path,
                                      self.inc_order,
                                      self._processed_file_dir,
                                      self._include_reader.current_file_dir,
                                      self.inc_flag_dirs)

        if inc_file and os.path.abspath(inc_file).startswith(self.inc_root):
            self._include_reader.include(open(inc_file, 'r'),
                                         os.path.dirname(inc_file))
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


class DependencyParser:
    _re_include = re.compile(r'^\s*include\s+(\'|")(.*?)\1', re.I)
    _re_line_continue_start = re.compile(r'^(.*)&\s*$')
    _re_line_continue_end = re.compile(r'^\s*&')
    _re_line_split = re.compile(
        r'^((?:[^\'";]|(?:\'(?:\\\'|[^\'\\])*\')|(?:"(?:\\"|[^"\\])*"))*);'
        r'(.*)$')
    _re_module_provide = re.compile(r'^\s*module\s+(?!procedure\s)(\w+)', re.I)
    _re_module_require = re.compile(
        r'^\s*use(?:\s+(?:::)?|\s*(?:,\s*\w+\s*)?::)\s*(\w+)', re.I)

    def __init__(self, stream, parsed_file_dir):
        # input properties
        self.inc_order = []
        self.inc_root = ''
        self.inc_flag_dirs = []
        self.external_mods = set()

        # output properties
        self.provided_modules = set()
        self.required_modules = set()
        self.included_files = set()

        # private members
        self._parsed_file_dir = parsed_file_dir
        self._include_reader = ContiguousIncludeReader()
        self._include_reader.include(stream, parsed_file_dir)

        self._line_buf = None

    def parse(self):
        while True:
            line = self._next_line()

            if not line:
                break

            # delete comments
            line = re.sub(r'!.*', '', line, 1)
            if line.isspace():
                continue

            # line continuation
            match = DependencyParser._re_line_continue_start.match(line)
            while match:
                next_line = self._next_line()
                if not next_line:
                    break
                line = match.group(1) + re.sub(
                    DependencyParser._re_line_continue_end, '', next_line)

                match = DependencyParser._re_line_continue_start.match(line)

            # replace non-quoted semicolons (;) with new lines (\n)
            match = DependencyParser._re_line_split.match(line)
            if match:
                self._line_buf = match.group(2) + '\n'
                if match.group(1):
                    line = match.group(1) + '\n'
                else:
                    continue

            # module provided
            match = DependencyParser._re_module_provide.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self.external_mods:
                    self.provided_modules.add(module_name)
                continue

            # module required
            match = DependencyParser._re_module_require.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self.external_mods:
                    self.required_modules.add(module_name)
                continue

            # include statement
            match = DependencyParser._re_include.match(line)
            if match:
                self._include(match.group(2))
                continue

    def _next_line(self):
        if self._line_buf is None:
            line = self._include_reader.readline()
        else:
            line = self._line_buf
            self._line_buf = None
        return line

    def _include(self, file_path):
        inc_file = find_included_file(file_path,
                                      self.inc_order,
                                      self._parsed_file_dir,
                                      self._include_reader.current_file_dir,
                                      self.inc_flag_dirs)

        if inc_file and os.path.abspath(inc_file).startswith(self.inc_root):
            self._include_reader.include(open(inc_file, 'r'),
                                         os.path.dirname(inc_file))
            self.included_files.add(inc_file)


def form_mod_file_names(mods, mod_dir, mod_ext, to_upper):
    base_names = (map(lambda s: s.upper(), mods)
                  if to_upper else mods.__iter__())
    return map(lambda s: os.path.join(mod_dir, s + '.' + mod_ext), base_names)


def main():
    args = get_args()

    print('Generating %s...' % args.output)

    debug_file = open(args.output + '.debug', 'w') if args.debug else None

    if debug_file:
        debug_file.writelines([
            '# Python version: ', sys.version.replace('\n', ' '), '\n',
            '# Command:\n',
            '  ', '\n    '.join(sys.argv), '\n',
            '# Parsed arguments:\n ',
            '\n '.join(
                [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])

    input_file_dir = os.path.dirname(args.input)

    pp = Preprocessor(open(args.input, 'r'), input_file_dir, args.debug)
    pp.inc_order = args.inc_pp_order
    pp.inc_root = args.inc_root
    pp.inc_flag_dirs = args.inc_dirs
    pp.try_eval_expr = args.try_eval_pp_expr

    for macro_def in args.macro_defs:
        pp.define_from_cmd_line(macro_def)

    parser = DependencyParser(pp, input_file_dir)
    parser.inc_order = args.inc_order
    parser.inc_root = args.inc_root
    parser.inc_flag_dirs = args.inc_dirs
    parser.external_mods = args.external_mods

    parser.parse()

    if debug_file:
        debug_file.writelines([
            '# Conditional preprocessor statements:\n ',
            '\n '.join([expr[:-1] + ' = ' + result
                        for expr, result in pp.if_expressions]), '\n'])

    debug_file.close()

    rule_dep_on_src = (args.compile_target + ' ' + args.output +
                       ' : ' + args.compile_src_prereq)
    included_files = pp.included_files | parser.included_files
    if included_files:
        rule_dep_on_src += ' ' + ' '.join(included_files)

    rules = [rule_dep_on_src + '\n']

    if parser.provided_modules:
        provided_mod_files = ' '.join(
            form_mod_file_names(parser.provided_modules,
                                args.mod_out_dir,
                                args.mod_file_ext,
                                args.mod_file_upper))
        rules.append(provided_mod_files + ' : ' + args.compile_target + '\n')

    if parser.required_modules:
        required_mod_files = ' '.join(
            form_mod_file_names(parser.required_modules,
                                args.mod_out_dir,
                                args.mod_file_ext,
                                args.mod_file_upper))
        rules.append(args.compile_target + ' : ' + required_mod_files + '\n')

    with open(args.output, 'w') as out:
        out.writelines(rules)


if __name__ == "__main__":
    main()