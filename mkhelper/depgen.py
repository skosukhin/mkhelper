#!/usr/bin/env python
import os
import sys

import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description='Generates OUTPUT makefile containing dependency rules '
                    'for the INPUT source file. Recognizes preprocessor '
                    '"#include", "#if" and associated directives as well as '
                    'Fortran "include", "use" and "module" statements.')

    parser.add_argument(
        'input', metavar='INPUT', type=argparse.FileType('r'),
        help='input source file')
    parser.add_argument(
        'output', metavar='OUTPUT', type=argparse.FileType('w'),
        help='output makefile with generated dependency rules')
    parser.add_argument(
        '--debug-file', metavar='DEBUG_FILE', type=argparse.FileType('w'),
        help='dump debug information to DEBUG_FILE')
    parser.add_argument(
        '--target',
        help='target of the compilation rule as it will appear in the '
             'generated makefile; normally equals to the path to the object '
             'file that is supposed to be generated as a result of '
             'compilation (by default, equals to name of the INPUT without '
             'directory prefix and with extension replaced with ".o")')
    parser.add_argument(
        '--src-prereq',
        help='source file prerequisite of the compilation rule as it will '
             'appear in the generated makefile; normally (and by default) '
             'equals to INPUT but, for example, can be set to the '
             'filename part of the INPUT if vpath feature is used')
    parser.add_argument(
        '--src-root', metavar='SRC_ROOT',
        help='ignore dependencies on files that are not in SRC_ROOT or '
             'its subdirectories; location of INPUT is not checked; '
             'the current working directory (i.e. where the building takes '
             'place) and its subdirectories are never ignored to allow for '
             'dependencies of/on automatically generated files (i.e. '
             'config.h)')
    parser.add_argument(
        'sep', metavar='-- [$CPPFLAGS | $FCFLAGS]',
        action='store_const', const='--',
        help='actual flags to be used in compilation, i.e. $(CPPFLAGS) or '
             '$(FCFLAGS), must be given at the end of the command line '
             'following the double dash separator (--); the program searches '
             'these flags for (possibly multiple instances of) -I, '
             'MACRO_FLAG and MOD_DIR_FLAG; any values found are used in '
             'the dependency generation of OUTPUT (in the case of '
             'MOD_DIR_FLAG, only the last value found is used.')

    pp_arg_group = parser.add_argument_group('preprocessor arguments')
    pp_arg_group.add_argument(
        '--pp-enable', action='store_true',
        help='enable the preprocessing stage; if disabled (default),all '
             'arguments of this argument group are ignored')
    pp_arg_group.add_argument(
        '--pp-eval-expr', action='store_true',
        help='enable evaluation of expressions that appear in preprocessor '
             'directives "#if" and "#elif"; if disabled (default) or '
             'evaluation fails, both branches of the directives are included '
             'by the preprocessing stage.')
    pp_arg_group.add_argument(
        '--pp-inc-order', default='inc,flg', metavar='ORDER_LIST',
        type=lambda s: s.lower().split(','),
        help='directory search order of files included using the preprocessor '
             '"#include" directive; ORDER_LIST is an ordered comma-separated '
             'list of keywords, the corresponding search paths of which are '
             'to be searched in the given order. The recognized keywords are: '
             '"cwd" (for the current working directory), "flg" (for the '
             'directories specified with -I compiler flag), "src" (for the '
             'directory containing the INPUT source file), and "inc" (for the '
             'directory containing the file with the "#include" directive. '
             '(default: %(default)s)')
    pp_arg_group.add_argument(
        '--pp-macro-flag', metavar='MACRO_FLAG', default='-D',
        help='preprocessor flag used for macro definition; only flags '
             'starting with a single dash (-) are currently supported '
             '(default: %(default)s)')

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
        type=lambda s: s.lower().split(','),
        help='equivalent to the "--pp-inc-order" argument, only for the '
             'Fortran "include" statement. (default: %(default)s)')
    fc_arg_group.add_argument(
        '--fc-intrinsic-mods', metavar='IGNORED_MODULES',
        type=lambda s: s.lower().split(','),
        default='iso_c_binding,iso_fortran_env,ieee_exceptions,'
                'ieee_arithmetic,ieee_features,omp_lib,omp_lib_kinds,openacc',
        help='comma-separated list of common Fortran intrinsic modules that '
             'usually need to be ignored when generating dependency rules '
             '(see also --fc-external-mods) (default: %(default)s)')
    fc_arg_group.add_argument(
        '--fc-external-mods', default=[], metavar='IGNORED_MODULES',
        type=lambda s: s.lower().split(','), dest='fc_ignored_mods',
        help='comma-separated list of external (to the project) Fortran '
             'modules to be ignored when generating dependency rules (extends '
             'the list provided with --fc-intrinsic-mods)')
    fc_arg_group.add_argument(
        '--fc-mod-dir-flag', metavar='MOD_DIR_FLAG', default='-J',
        help='Fortran compiler flag used to specify the directory where '
             'module files are saved; only flags starting with a single dash '
             '(-) are currently supported (default: %(default)s)')

    args, unknown = parser.parse_known_args()

    if unknown:
        if unknown[0] != '--':
            parser.error('unknown argument %s' % unknown[0])
        else:
            unknown = unknown[1:]

    if not args.target:
        args.target = os.path.splitext(
            os.path.basename(args.input.name))[0] + '.o'
    if not args.src_prereq:
        args.src_prereq = args.input.name
    if args.src_root:
        args.src_root = os.path.abspath(args.src_root)

    compiler_args = dict(pp_inc_dirs='-I',
                         pp_macros=args.pp_macro_flag,
                         fc_inc_dirs='-I',
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
        args.fc_ignored_mods = set(args.fc_ignored_mods +
                                   args.fc_intrinsic_mods)
        del args.fc_intrinsic_mods

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

    print('Generating \'%s\'...' % args.output.name)

    if args.debug_file:
        args.debug_file.writelines([
            '# Python version: ', sys.version.replace('\n', ' '), '\n',
            '# Command:\n',
            '  ', '\n    '.join(sys.argv), '\n',
            '# Parsed arguments:\n ',
            '\n '.join(
                [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])

    if args.pp_enable:
        from depgen.pp_c import CPreprocessor
        pp = CPreprocessor(
            args.input,
            include_root=args.src_root,
            include_dirs=args.pp_inc_dirs,
            include_order=args.pp_inc_order,
            try_eval_expr=args.pp_eval_expr,
            debug=bool(args.debug_file))

        for macro in args.pp_macros:
            pp.define_from_cmd_line(macro)
    else:
        from depgen.pp_dummy import DummyPreprocessor
        pp = DummyPreprocessor(args.input)

    if args.fc_enable:
        from depgen.gen_fortran import FortranGenerator
        generator = FortranGenerator(
            pp,
            include_root=args.src_root,
            include_dirs=args.fc_inc_dirs,
            include_order=args.fc_inc_order,
            mods_to_ignore=args.fc_ignored_mods,
            mod_file_dir=args.fc_mod_dir,
            mod_file_ext=args.fc_mod_ext,
            mod_file_upper=args.fc_mod_upper,
            debug=bool(args.debug_file))
    else:
        from depgen.gen_pp import PpGenerator
        generator = PpGenerator(pp)

    generator.parse()

    if args.debug_file:
        generator.print_debug(args.debug_file)

    args.output.writelines(
        generator.gen_dep_rules(args.target,
                                args.output.name,
                                args.src_prereq))
    args.output.close()

    if args.debug_file:
        args.debug_file.close()


if __name__ == "__main__":
    main()
