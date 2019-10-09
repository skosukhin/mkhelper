#!/usr/bin/env python
import os
import sys

from depgen import StreamWrapper, open23

try:
    import argparse
except ImportError:
    import _argparse as argparse


def parse_args():
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Generates OUTPUT makefile containing dependency rules '
                    'for the INPUT source file. Recognizes preprocessor '
                    '`#include`, `#if` and associated directives as well as '
                    'Fortran `INCLUDE`, `USE` and `MODULE` statements.')

    def comma_splitter(s):
        return list(filter(None, s.lower().split(',')))

    def path_splitter(s):
        return list(filter(None, s.split(':')))

    parser.add_argument(
        'input', metavar='INPUT',
        help='input source file; if equals to a single dash (-), the program '
             'reads from the standard input stream')
    parser.add_argument(
        '--output', '-o', metavar='OUTPUT',
        help='output makefile with generated dependency rules; if not '
             'specified or equals to a single dash (-), the program writes to '
             'the standard output stream')
    parser.add_argument(
        '--debug', '-d', action='store_true',
        help='dump debug information to OUTPUT (commented with `#`)')
    parser.add_argument(
        '--src-name', metavar='SRC_NAME',
        help='name of the source file, the prerequisite of the corresponding '
             'compilation rule as it will appear in the OUTPUT; normally (and '
             'by default) equals to the INPUT or to an empty string when the '
             'latter is set to the standard input stream')
    parser.add_argument(
        '--obj-name', metavar='OBJ_NAME',
        help='name of the object file, the target of the corresponding '
             'compilation rule as it will appear in the OUTPUT; normally '
             'equals to the path to the object file that is supposed to be '
             'generated as a result of compilation (default: SRC_NAME '
             'without the directory-part and the file extension replaced '
             'with `.o`)')
    parser.add_argument(
        '--dep-name',
        help='name of the generated makefile, the additional target of the '
             'corresponding compilation rule (for automatic dependency '
             'generation) as it will appear in the OUTPUT; normally (and by '
             'default) equals to the OUTPUT or to an empty string when the '
             'latter is set to the standard output stream)')
    parser.add_argument(
        '--src-roots', metavar='SRC_ROOTS',
        type=path_splitter,
        help='colon-separated list of paths to directories; if specified and '
             'not empty, dependencies on files that do not reside in one of '
             'the specified directories will be ignored; applies only to '
             'files included using the preprocessor `#include` directive or '
             'the Fortran `INCLUDE` statement')
    # parser.add_argument(
    #     '--lc-enable', action='store_true',
    #     help='enable recognition of the preprocessor line control directives '
    #          'and generation of additional dependencies based on the detected '
    #          'filenames')
    parser.add_argument(
        'flags', metavar='-- [$CPPFLAGS | $FCFLAGS]', nargs='?',
        default=argparse.SUPPRESS,
        help='actual flags to be used in compilation, i.e. $(CPPFLAGS) or '
             '$(FCFLAGS), must be given at the end of the command line '
             'following the double dash separator (--); the program searches '
             'these flags for (possibly multiple instances of) PP_INC_FLAG, '
             'PP_MACRO_FLAG, FC_INC_FLAG and FC_MOD_DIR_FLAG; any values '
             'found are used in the dependency generation (in the case of '
             'FC_MOD_DIR_FLAG, only the last value found is used)')

    pp_arg_group = parser.add_argument_group('preprocessor arguments')
    pp_arg_group.add_argument(
        '--pp-enable', action='store_true',
        help='enable the preprocessing stage; if disabled (default), all '
             'arguments of this argument group are ignored')
    pp_arg_group.add_argument(
        '--pp-eval-expr', action='store_true',
        help='enable evaluation of expressions that appear in preprocessor '
             'directives `#if` and `#elif` (does not apply to `#ifdef` and '
             '`#ifndef`, which are always evaluated); if disabled (default) '
             'or evaluation fails, both branches of the directives are '
             'included by the preprocessing stage')
    pp_arg_group.add_argument(
        '--pp-inc-sys', action='store_true',
        help='enable recognition of dependencies specified with the '
             'angle-bracket form of the preprocessor `#include` directive '
             '(i.e. `#include <filename>`); the constraint set by SRC_ROOTS '
             'applies')
    pp_arg_group.add_argument(
        '--pp-inc-order', default='inc,flg', metavar='ORDER_LIST',
        type=comma_splitter,
        help='directory search order of files included using the quoted form '
             'of the preprocessor `#include` directive (i.e. `#include '
             '"filename"`) ; ORDER_LIST is an ordered comma-separated list of '
             'keywords, the corresponding search paths of which are to be '
             'searched in the given order. The recognized keywords are: `cwd` '
             '(for the current working directory), `flg` (for the directories '
             'specified with PP_INC_FLAG compiler flag), `src` (for the '
             'directory containing the INPUT source file), and `inc` (for the '
             'directory containing the file with the `#include` directive). '
             'Default: `%(default)s`.')
    pp_arg_group.add_argument(
        '--pp-inc-sys-order', default='flg', metavar='ORDER_LIST',
        type=comma_splitter,
        help='equivalent to the `--pp-inc-order` argument, only for the '
             'angle-bracket form of the preprocessor `#include` directive '
             '(i.e. `#include <filename>`, default: `%(default)s`)')

    pp_arg_group.add_argument(
        '--pp-macro-flag', metavar='PP_MACRO_FLAG', default='-D',
        help='preprocessor flag used for macro definition; only flags '
             'that start with a single dash (-) and have no more than one '
             'trailing whitespace are supported (default: `%(default)s`)')
    pp_arg_group.add_argument(
        '--pp-inc-flag', metavar='PP_INC_FLAG', default='-I',
        help='preprocessor flag used for setting search paths for the '
             '`#include` directive; only flags that start with a single dash '
             '(-) and have no more than one trailing whitespace are supported '
             '(default: `%(default)s`)')

    fc_arg_group = parser.add_argument_group('Fortran arguments')
    fc_arg_group.add_argument(
        '--fc-enable', action='store_true',
        help='enable recognition of Fortran dependencies specified with '
             '`INCLUDE`, `USE` and `MODULE` statements; if disabled (default),'
             'all arguments of this argument group are ignored')
    fc_arg_group.add_argument(
        '--fc-mod-ext', default='mod',
        help='filename extension (without leading dot) of compiler-generated '
             'Fortran module files (default: `%(default)s`)')
    fc_arg_group.add_argument(
        '--fc-mod-upper', choices=['yes', 'no'], default='no',
        help='whether Fortran compiler-generated module files have uppercase '
             'names (default: `%(default)s`)')
    fc_arg_group.add_argument(
        '--fc-inc-order', default='src,flg', metavar='ORDER_LIST',
        type=comma_splitter,
        help='equivalent to the `--pp-inc-order` argument, only for the '
             'Fortran `INCLUDE` statement and FC_INC_FLAG (default: '
             '`%(default)s`)')
    fc_arg_group.add_argument(
        '--fc-intrinsic-mods', metavar='INTRINSIC_MODS_LIST',
        type=comma_splitter,
        default='iso_c_binding,iso_fortran_env,ieee_exceptions,'
                'ieee_arithmetic,ieee_features,omp_lib,omp_lib_kinds,openacc',
        help='comma-separated list of Fortran intrinsic modules. Fortran '
             'modules that are explicitly specified as intrinsic in the '
             'source file (i.e. `USE, INTRINSIC :: MODULENAME`) are ignored '
             'regardless of whether they are mentioned on the '
             'INTRINSIC_MODS_LIST. Fortran modules that are mentioned on the '
             'INTRINSIC_MODS_LIST are ignored only when their nature is not '
             'specified in the source file at all (i.e. `USE :: MODULENAME`). '
             'Fortran modules that need to be ignored unconditionally must '
             'be put on the EXTERNAL_MODS_LIST (see `--fc-external-mods`). '
             'Default: `%(default)s`.')
    fc_arg_group.add_argument(
        '--fc-external-mods', metavar='EXTERNAL_MODS_LIST',
        type=comma_splitter,
        help='comma-separated list of external (to the project) Fortran '
             'modules that need to be unconditionally ignored when generating '
             'dependency rules (see also `--fc-intrinsic-mods`)')
    fc_arg_group.add_argument(
        '--fc-mod-dir-flag', metavar='FC_MOD_DIR_FLAG', default='-J',
        help='Fortran compiler flag used to specify the directory where '
             'module files are saved; only flags that start with a single '
             'dash (-) and have no more than one trailing whitespace are '
             'supported (default: `%(default)s`)')
    fc_arg_group.add_argument(
        '--fc-inc-flag', metavar='FC_INC_FLAG', default='-I',
        help='preprocessor flag used for setting search paths for the '
             'Fortran `INCLUDE` statement; only flags that start with a '
             'single dash (-) and have no more than one trailing whitespace '
             'are supported (default: `%(default)s`)')

    unknown = []
    try:
        sep_idx = sys.argv.index('--')
        args = parser.parse_args(sys.argv[1:sep_idx])
        unknown = sys.argv[sep_idx + 1:]
    except ValueError:
        args = parser.parse_args()

    if not args.src_name:
        args.src_name = '' if args.input == '-' else args.input

    if not args.obj_name:
        src_no_ext_basename = os.path.splitext(
            os.path.basename(args.src_name))[0]
        if src_no_ext_basename:
            args.obj_name = src_no_ext_basename + '.o'
        else:
            args.obj_name = ''

    if not args.output:
        args.output = '-'

    if not args.dep_name:
        args.dep_name = '' if args.output == '-' else args.output

    compiler_arg_dests = dict()

    if args.pp_enable:
        compiler_arg_dests.update(pp_inc_dirs=args.pp_inc_flag,
                                  pp_macros=args.pp_macro_flag)

    if args.fc_enable:
        compiler_arg_dests.update(fc_inc_dirs=args.fc_inc_flag,
                                  fc_mod_dir=args.fc_mod_dir_flag)

    if compiler_arg_dests:
        compiler_args = dict()
        for dest, flag in compiler_arg_dests.items():
            if not flag.startswith('-') or flag.endswith('  '):
                parser.error('unsupported compiler/preprocessor flag ' + flag)
            # Several dests might share the same flag and we want them to share
            # the same list of values in this the case:
            val_list = compiler_args.get(flag, None)
            if val_list is None:
                val_list = []
                compiler_args[flag] = val_list
            setattr(args, dest, val_list)

        appended_val_lists = []
        for arg in unknown:
            if arg.startswith('-'):
                appended_val_lists *= 0
                arg_ws = arg + ' '
                for flag, val_list in compiler_args.items():
                    if flag == arg or flag == arg_ws:
                        # If the current argument equals to a flag, which might
                        # have a significant trailing whitespace, the next
                        # argument on the command line is the flag's value:
                        appended_val_lists.append(val_list)
                    elif arg.startswith(flag):
                        # If the current argument starts with a flag that does
                        # not have a trailing whitespace, the suffix of the
                        # argument is the flag's value:
                        val_list.append(arg[len(flag):])
            elif appended_val_lists:
                for val_list in appended_val_lists:
                    val_list.append(arg)
                appended_val_lists *= 0

    if args.fc_enable:
        args.fc_mod_upper = (args.fc_mod_upper == 'yes')
        if args.fc_mod_dir:
            args.fc_mod_dir = args.fc_mod_dir[-1]
        else:
            args.fc_mod_dir = None

    return args


def main():
    args = parse_args()

    input_stream = StreamWrapper(sys.stdin, '') if args.input == '-' \
        else open23(args.input, 'r')

    parser = None

    included_files = set()

    def include_callback(filename):
        included_files.add(filename)

    provided_modules = set()

    def module_callback(module):
        provided_modules.add(module)

    required_modules = set()

    def use_module_callback(module):
        required_modules.add(module)

    pp_debug_info = None
    ftn_debug_info = None

    if args.pp_enable:
        from depgen.preprocessor import Preprocessor

        pp = Preprocessor(input_stream,
                          include_order=args.pp_inc_order,
                          include_sys_order=args.pp_inc_sys_order,
                          include_dirs=args.pp_inc_dirs,
                          include_roots=args.src_roots,
                          try_eval_expr=args.pp_eval_expr,
                          inc_sys=args.pp_inc_sys)
        for pp_macro in args.pp_macros:
            pp.define(pp_macro)

        pp.include_callback = include_callback

        def debug_callback(line, msg):
            pp_debug_info.append('#  `%s`:\t%s\n' % (line[:-1], msg))

        if args.debug:
            pp_debug_info = ['#\n# Preprocessor:\n']
            pp.debug_callback = debug_callback

        input_stream = pp
        parser = pp

    if args.fc_enable:
        from depgen.fortran_parser import FortranParser
        ftn = FortranParser(input_stream,
                            include_order=args.fc_inc_order,
                            include_dirs=args.fc_inc_dirs,
                            include_roots=args.src_roots,
                            intrinsic_mods=args.fc_intrinsic_mods,
                            external_mods=args.fc_external_mods)

        ftn.include_callback = include_callback
        ftn.module_callback = module_callback
        ftn.use_module_callback = use_module_callback

        def debug_callback(line, msg):
            ftn_debug_info.append('#  `%s`:\t%s\n' % (line[:-1], msg))

        if args.debug:
            ftn_debug_info = ['#\n# Fortran parser:\n']
            ftn.debug_callback = debug_callback

        parser = ftn

    if parser:
        parser.parse()

    input_stream.close()

    output_stream = sys.stdout if args.output == '-' \
        else open23(args.output, 'w')
    output_lines = []
    targets = ('%s %s' % (args.obj_name, args.dep_name)).strip()
    if targets:
        prereqs = ('%s %s' % (args.src_name, ' '.join(included_files))).strip()
        if prereqs:
            output_lines.append('%s: %s\n' % (targets, prereqs))
    if provided_modules:
        if args.obj_name:
            targets = ' '.join(modulenames_to_filenames(
                provided_modules, args.fc_mod_dir,
                args.fc_mod_upper, args.fc_mod_ext))
            output_lines.append('%s: %s\n' % (targets, args.obj_name))
    # Do not depend on the modules that are provided in the same file:
    required_modules -= provided_modules
    if required_modules:
        if args.obj_name:
            prereqs = ' '.join(modulenames_to_filenames(
                required_modules, args.fc_mod_dir,
                args.fc_mod_upper, args.fc_mod_ext))
            output_lines.append('%s: %s\n' % (args.obj_name, prereqs))
    if args.debug:
        if args.debug:
            output_lines.extend([
                '\n# Python version: ', sys.version.replace('\n', ' '),
                '\n#\n',
                '# Command:\n',
                '#  ', ' '.join(sys.argv), '\n#\n',
                '# Parsed arguments:\n#  ',
                '\n#  '.join(
                    [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])
            if pp_debug_info is not None:
                output_lines.extend(pp_debug_info)
            if ftn_debug_info is not None:
                output_lines.extend(ftn_debug_info)
    output_stream.writelines(output_lines)
    output_stream.close()


def modulenames_to_filenames(modules, directory, upprecase, extension):
    result = modules
    if upprecase:
        result = map(lambda s: s.upper(), result)
    if directory:
        result = map(lambda s: os.path.join(directory, s), result)
    if extension:
        result = map(lambda s: '%s.%s' % (s, extension), result)
    return result


if __name__ == "__main__":
    main()
