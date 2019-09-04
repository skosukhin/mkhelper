#!/usr/bin/env python
import os
import sys

from depgen import open23

try:
    import argparse
except ImportError:
    import _argparse as argparse


def parse_args():
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Generates OUTPUT makefile containing dependency rules '
                    'for the INPUT source file. Recognizes preprocessor '
                    '"#include", "#if" and associated directives as well as '
                    'Fortran "include", "use" and "module" statements.')

    def comma_splitter(s):
        return list(filter(None, s.lower().split(',')))

    parser.add_argument(
        'input', metavar='INPUT',
        help='input source file')
    parser.add_argument(
        '--output', '-o', metavar='OUTPUT',
        help='output makefile with generated dependency rules; if not '
             'specified, the program writes to the standard output')
    parser.add_argument(
        '--debug-file', '-d', metavar='DEBUG_FILE',
        help='dump debug information to DEBUG_FILE')
    parser.add_argument(
        '--obj-name', metavar='OBJ_NAME',
        help='name of the object file, the target of the corresponding '
             'compilation rule as it will appear in the OUTPUT; normally '
             'equals to the path to the object file that is supposed to be '
             'generated as a result of compilation (by default, equals to the '
             'name of the INPUT without the directory-part with the file '
             'extension replaced with ".o")')
    parser.add_argument(
        '--src-name',
        help='name of the source file, the prerequisite of the corresponding '
             'compilation rule as it will appear in the OUTPUT; normally (and '
             'by default) equals to the INPUT but can be overridden when, for '
             'example, the source file needs to be referenced in the OUTPUT '
             'without the directory-part (i.e. source files in the calling '
             'Makefile are located using the vpath feature)')
    parser.add_argument(
        '--dep-name',
        help='name of the generated makefile, the additional target of the'
             'corresponding compilation rule (for auto-dependency generation) '
             'as it will appear in the OUTPUT; normally (and by default) '
             'equals to the OUTPUT but can be explicitly set when the latter '
             'is not specified (i.e. writing to the standard output stream)')
    parser.add_argument(
        '--oo-prereqs', metavar='ORDER_ONLY_PREREQUISITE_LIST',
        type=comma_splitter,
        help='comma-separated list of additional order only prerequisites of '
             'the OBJ_NAME')
    parser.add_argument(
        '--src-root', metavar='SRC_ROOT',
        help='ignore dependencies on files that are not in SRC_ROOT or '
             'its subdirectories; location of INPUT is not checked; '
             'the current working directory (i.e. where the building takes '
             'place) and its subdirectories are never ignored to allow for '
             'dependencies of/on automatically generated files (i.e. '
             'config.h)')
    parser.add_argument(
        'flags', metavar='-- [$CPPFLAGS | $FCFLAGS]', nargs='?',
        default=argparse.SUPPRESS,
        help='actual flags to be used in compilation, i.e. $(CPPFLAGS) or '
             '$(FCFLAGS), must be given at the end of the command line '
             'following the double dash separator (--); the program searches '
             'these flags for (possibly multiple instances of) PP_INC_FLAG, '
             'PP_MACRO_FLAG, FC_INC_FLAG and FC_MOD_DIR_FLAG; any values '
             'found are used in the dependency generation of OUTPUT (in the '
             'case of FC_MOD_DIR_FLAG, only the last value found is used.')

    pp_arg_group = parser.add_argument_group('preprocessor arguments')
    pp_arg_group.add_argument(
        '--pp-enable', action='store_true',
        help='enable the preprocessing stage; if disabled (default), all '
             'arguments of this argument group are ignored')
    pp_arg_group.add_argument(
        '--pp-eval-expr', action='store_true',
        help='enable evaluation of expressions that appear in preprocessor '
             'directives "#if" and "#elif"; if disabled (default) or '
             'evaluation fails, both branches of the directives are included '
             'by the preprocessing stage.')
    pp_arg_group.add_argument(
        '--pp-inc-order', default='inc,flg', metavar='ORDER_LIST',
        type=comma_splitter,
        help='directory search order of files included using the preprocessor '
             '"#include" directive; ORDER_LIST is an ordered comma-separated '
             'list of keywords, the corresponding search paths of which are '
             'to be searched in the given order. The recognized keywords are: '
             '"cwd" (for the current working directory), "flg" (for the '
             'directories specified with PP_INC_FLAG compiler flag), "src" '
             '(for the directory containing the INPUT source file), and "inc" '
             '(for the directory containing the file with the "#include" '
             'directive. Default: "%(default)s".')
    pp_arg_group.add_argument(
        '--pp-macro-flag', metavar='PP_MACRO_FLAG', default='-D',
        help='preprocessor flag used for macro definition; only flags '
             'starting with a single dash (-) are currently supported '
             '(default: %(default)s)')
    pp_arg_group.add_argument(
        '--pp-inc-flag', metavar='PP_INC_FLAG', default='-I',
        help='preprocessor flag used for setting search paths for the '
             '"#include" directive; only flags starting with a single dash '
             '(-) are currently supported (default: %(default)s)')

    fc_arg_group = parser.add_argument_group('Fortran arguments')
    fc_arg_group.add_argument(
        '--fc-enable', action='store_true',
        help='enable recognition of Fortran dependencies specified with '
             '"include", "use" and "module" statements; if disabled (default),'
             'all arguments of this argument group are ignored')
    fc_arg_group.add_argument(
        '--fc-mod-ext', default='mod',
        help='filename extension (without leading dot) of compiler-generated '
             'Fortran module files (default: %(default)s)')
    fc_arg_group.add_argument(
        '--fc-mod-upper', choices=['yes', 'no'], default='no',
        help='whether Fortran compiler-generated module files have uppercase '
             'names (default: %(default)s)')
    fc_arg_group.add_argument(
        '--fc-inc-order', default='src,flg', metavar='ORDER_LIST',
        type=comma_splitter,
        help='equivalent to the "--pp-inc-order" argument, only for the '
             'Fortran "include" statement and FC_INC_FLAG (default: '
             '"%(default)s")')
    fc_arg_group.add_argument(
        '--fc-intrinsic-mods', metavar='INTRINSIC_MODS_LIST',
        type=comma_splitter,
        default='iso_c_binding,iso_fortran_env,ieee_exceptions,'
                'ieee_arithmetic,ieee_features,omp_lib,omp_lib_kinds,openacc',
        help='comma-separated list of Fortran intrinsic modules. Fortran '
             'modules that are explicitly specified as intrinsic in the '
             'source file (i.e. "use, intrinsic :: <modulename>") are ignored '
             'regardless of whether they are mentioned on the '
             'INTRINSIC_MODS_LIST. Fortran modules that are mentioned on the '
             'INTRINSIC_MODS_LIST are ignored only when their nature is not '
             'specified in the source file at all (i.e. "use :: '
             '<modulename>"). Fortran modules that need to be ignored '
             'unconditionally must be put on the EXTERNAL_MODS_LIST (see '
             '--fc-external-mods). Default: "%(default)s".')
    fc_arg_group.add_argument(
        '--fc-external-mods', metavar='EXTERNAL_MODS_LIST',
        type=comma_splitter,
        help='comma-separated list of external (to the project) Fortran '
             'modules that need to be unconditionally ignored when generating '
             'dependency rules (see also --fc-intrinsic-mods)')
    fc_arg_group.add_argument(
        '--fc-mod-dir-flag', metavar='FC_MOD_DIR_FLAG', default='-J',
        help='Fortran compiler flag used to specify the directory where '
             'module files are saved; only flags starting with a single dash '
             '(-) are currently supported (default: %(default)s)')
    fc_arg_group.add_argument(
        '--fc-inc-flag', metavar='FC_INC_FLAG', default='-I',
        help='preprocessor flag used for setting search paths for the '
             'Fortran "include" statement; only flags starting with a single '
             'dash (-) are currently supported (default: %(default)s)')

    unknown = []
    try:
        sep_idx = sys.argv.index('--')
        args = parser.parse_args(sys.argv[1:sep_idx])
        unknown = sys.argv[sep_idx + 1:]
    except ValueError:
        args = parser.parse_args()

    if not args.obj_name:
        args.obj_name = os.path.splitext(
            os.path.basename(args.input))[0] + '.o'
    if not args.src_name:
        args.src_name = args.input
    if not args.dep_name and args.output:
        args.dep_name = args.output
    if args.src_root:
        args.src_root = os.path.abspath(args.src_root)

    compiler_args = dict(pp_inc_dirs=args.pp_inc_flag,
                         pp_macros=args.pp_macro_flag,
                         fc_inc_dirs=args.fc_inc_flag,
                         fc_mod_dir=args.fc_mod_dir_flag)

    for dest, flag in compiler_args.items():
        if not flag.startswith('-') or flag.endswith('  '):
            parser.error('unsupported compiler/preprocessor flag ' + flag)
        setattr(args, dest, None)

    enabled_compiler_args = []

    if args.pp_enable:
        for dest in compiler_args.keys():
            if dest.startswith('pp_'):
                enabled_compiler_args.append(dest)

    if args.fc_enable:
        for dest in compiler_args.keys():
            if dest.startswith('fc_'):
                enabled_compiler_args.append(dest)
        args.fc_mod_upper = args.fc_mod_upper == 'yes'

    if enabled_compiler_args:
        compiler_flags = dict()
        for dest in enabled_compiler_args:
            flag = compiler_args[dest]
            parse_result = compiler_flags.get(flag, None)
            if parse_result is None:
                parse_result = []
                compiler_flags[flag] = parse_result
            setattr(args, dest, parse_result)

        appended_results = []
        for compiler_arg in unknown:
            if compiler_arg.startswith('-'):
                appended_results[:] = []
                compiler_arg_ws = compiler_arg + ' '
                for flag, result in compiler_flags.items():
                    if compiler_arg == flag or compiler_arg_ws == flag:
                        appended_results.append(result)
                    elif compiler_arg.startswith(flag):
                        result.append(compiler_arg[len(flag):].strip())
            else:
                if appended_results:
                    for result in appended_results:
                        result.append(compiler_arg)
                appended_results[:] = []

        if args.fc_mod_dir and args.fc_mod_dir[-1]:
            args.fc_mod_dir = args.fc_mod_dir[-1]
        else:
            args.fc_mod_dir = None

    return args


def main():
    args = parse_args()

    debug_file = None
    if args.debug_file:
        debug_file = open(args.debug_file, 'w')
        debug_file.writelines([
            '# Python version: ', sys.version.replace('\n', ' '), '\n',
            '# Command:\n',
            '  ', '\n    '.join(sys.argv), '\n',
            '# Parsed arguments:\n ',
            '\n '.join(
                [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])

    in_stream = open23(args.input, 'r')

    if args.pp_enable:
        from depgen.pp import Preprocessor
        pp = Preprocessor(
            in_stream,
            include_root=args.src_root,
            include_dirs=args.pp_inc_dirs,
            include_order=args.pp_inc_order,
            try_eval_expr=args.pp_eval_expr,
            debug=(debug_file is not None))

        for macro in args.pp_macros:
            pp.define_from_cmd_line(macro)
    else:
        from depgen.pp_dummy import DummyPreprocessor
        pp = DummyPreprocessor(in_stream)

    if args.fc_enable:
        from depgen.gen_fortran import FortranGenerator
        generator = FortranGenerator(
            pp,
            include_root=args.src_root,
            include_dirs=args.fc_inc_dirs,
            include_order=args.fc_inc_order,
            intrinsic_mods=args.fc_intrinsic_mods,
            external_mods=args.fc_external_mods,
            mod_file_dir=args.fc_mod_dir,
            mod_file_ext=args.fc_mod_ext,
            mod_file_upper=args.fc_mod_upper,
            debug=(debug_file is not None))
    else:
        from depgen.gen_pp import PpGenerator
        generator = PpGenerator(pp)

    generator.parse()

    out_stream = open(args.output, 'w') if args.output else sys.stdout

    out_stream.writelines(
        generator.gen_dep_rules(
            args.obj_name, args.dep_name, args.src_name,
            extra_order_prereqs=args.oo_prereqs))

    out_stream.close()

    if debug_file:
        generator.print_debug(debug_file)
        debug_file.close()


if __name__ == "__main__":
    main()
