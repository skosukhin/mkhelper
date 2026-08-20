MKH_SUBDIR_ACCEPT_CMAKE_DEFINITIONS([-DBUILD_SHARED_LIBS*])
MKH_POLYMORPHIC_OPTION([enable], [example-*], [mkh_examples])

AC_INIT([mkhelper], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_SRCDIR([src/program/main.f90])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AC_PREFIX_DEFAULT(["`pwd`/install"])

AC_CANONICAL_HOST
MKH_HOST_FQDN([AC_SUBST([host_fqdn], [$mkh_cv_host_fqdn])])

MKH_BUILD_ENVIRONMENT

AC_ARG_ENABLE([rpaths],
  [AS_HELP_STRING([--enable-rpaths],
     [prepend LDFLAGS with additional linker flags to add directories specified
with -L flags to the runtime library search path (RPATH)
@<:@default=yes@:>@])], [],
  [enable_rpaths=yes])

MKH_COMPILER_CROSS_CHECK_DELAY
AC_PROG_FC
export FC
AC_LANG([Fortran])
MKH_FC_PP_SRCEXT([f90])
MKH_COMPILER_FC_VERSION
AC_SUBST([FC_VENDOR], [$mkh_cv_fc_compiler_vendor])

AS_VAR_IF([enable_rpaths], [yes],
  [MKH_SHLIB_FC_RPATH_FLAG
   MKH_SHLIB_PATH_VAR
   eval link_cmd="\"$ac_link\""
   MKH_EXTRACT_ARGS([mkhelper_libdirs], [`echo $link_cmd`], ['-L@<:@ @:>@*'])
   mkhelper_rpath_flags=
   for mkhelper_libdir in $mkhelper_libdirs; do
     AS_IF([test -d "$mkhelper_libdir"],
       [MKH_VAR_APPEND_UNIQ([mkhelper_rpath_flags],
          ["$mkh_cv_fc_rpath_flag$mkhelper_libdir"], [' '])
        MKH_VAR_APPEND_UNIQ([$mkh_cv_shlib_path_var],
          ["$mkhelper_libdir"], [':'])])
   done
   AS_IF([test -n "$mkhelper_rpath_flags"],
     [MKH_SHLIB_RPATH_FLAGS_CHECK([$mkhelper_rpath_flags],
        [LDFLAGS="$mkhelper_rpath_flags $LDFLAGS"])])
   eval export $mkh_cv_shlib_path_var])

MKH_SHLIB_EXT
MKH_SHLIB_FC_EXPORT_DYNAMIC_FLAG

MKH_COMPILER_CROSS_CHECK_NOW
MKH_FC_LINE_LENGTH([unlimited])

dnl Additional macro definitions to aid the dependency generator,
dnl e.g. compiler intrinsic macros:
AC_SUBST([DEPGEN_FCFLAGS], [''])

AC_SUBST([DEPGEN_INTRINSIC_MODS],
  [[iso_c_binding,iso_fortran_env,ieee_exceptions,ieee_arithmetic,]dnl
[ieee_features,omp_lib,omp_lib_kinds,openacc]])
AC_SUBST([DEPGEN_EXTERNAL_MODS])

MKH_FC_MODULE_IN_FLAG([AC_SUBST([FC_MOD_IN], [$mkh_cv_fc_module_in_flag])])
MKH_FC_MODULE_OUT_FLAG([AC_SUBST([FC_MOD_OUT], [$mkh_cv_fc_module_out_flag])])

MKH_FC_MODULE_NAMING(
  [AC_SUBST([FC_MOD_FILE_UPPER], [$mkh_cv_fc_module_naming_upper])
   AC_SUBST([FC_MOD_FILE_EXT], [$mkh_cv_fc_module_naming_ext])])

MKH_FC_MODULE_SNAMING(
  [AC_SUBST([FC_SMOD_FILE_INFIX], [$mkh_cv_fc_module_snaming_infix])
   AC_SUBST([FC_SMOD_FILE_EXT], [$mkh_cv_fc_module_snaming_ext])])

MKH_FC_MODULE_ROOT_SMOD(
  [AC_SUBST([FC_ROOT_SMOD], [$mkh_cv_fc_module_root_smod])])

AC_ARG_ENABLE([separate-mods],
  [AS_HELP_STRING([--enable-separate-mods],
     [enable the two-step compilation of the Fortran source files
@<:@default=yes@:>@])], [],
  [enable_separate_mods=yes])
AS_VAR_IF([enable_separate_mods], [yes],
  [MKH_FC_MODULE_ONLY_FLAG([FC_MOD_ONLY=$mkh_cv_fc_module_only_flag])
   SEPARATE_MODS_ENABLED=''
   SEPARATE_MODS_DISABLED='#'],
  [FC_MOD_ONLY=
   SEPARATE_MODS_ENABLED='#'
   SEPARATE_MODS_DISABLED=''])
AC_SUBST([FC_MOD_ONLY])
AC_SUBST([SEPARATE_MODS_ENABLED])
AC_SUBST([SEPARATE_MODS_DISABLED])

MKH_FC_INCLUDE_FLAG(
  [AC_SUBST([FC_INC_FLAG], [$mkh_cv_fc_ftn_include_flag])])
MKH_FC_INCLUDE_ORDER(
  [FC_INC_ORDER=$mkh_cv_fc_ftn_include_order],
  [FC_INC_ORDER=src,flg])
AC_SUBST([FC_INC_ORDER])

MKH_FC_INCLUDE_FLAG_PP(
  [AC_SUBST([FC_INC_FLAG_PP_f90], [$mkh_cv_fc_pp_include_flag])])
MKH_FC_INCLUDE_ORDER_PP(
  [FC_INC_ORDER_PP_f90=$mkh_cv_fc_pp_include_order],
  [FC_INC_ORDER_PP_f90=inc,flg])
AC_SUBST([FC_INC_ORDER_PP_f90])

MKH_FC_INCLUDE_FLAG_PP_SYS(
  [AS_IF([test "x$mkh_cv_fc_pp_sys_include_flag" != dnl
"x$mkh_cv_fc_pp_include_flag"],
     [AC_MSG_ERROR([Different flags needed to specify search paths for the dnl
quoted and the angle-bracket forms of the "#include" directive are not dnl
supported])])])
MKH_FC_INCLUDE_ORDER_PP_SYS(
  [FC_INC_ORDER_PP_SYS_f90=$mkh_cv_fc_pp_sys_include_order],
  [FC_INC_ORDER_PP_SYS_f90=flg])
AC_SUBST([FC_INC_ORDER_PP_SYS_f90])

MKH_LANG_MACRO_FLAG([AC_SUBST([FC_PP_DEF], [$mkh_cv_fc_macro_flag])])

MKH_FC_PP_COMMENTS([], [:])

MKH_FC_MISMATCH([], [:])

MKH_FC_ENDIANNESS_REAL([], [], [:])

AC_SUBST([config_FCFLAGS])

AC_ARG_VAR([FPP], [Fortran preprocessor command])
MKH_PROG_FPP([FPP], [FPP=$mkh_cv_prog_fpp], [FPP=],
  [$FC_INC_FLAG_PP_f90], [$FC_PP_DEF])

AC_ARG_ENABLE([silent-rules],
  [AS_HELP_STRING([--enable-silent-rules],
     [less verbose build output (undo: "make V=1") @<:@default=yes@:>@])], [],
  [enable_silent_rules=yes])
AS_VAR_IF([enable_silent_rules], [yes],
  [DEFAULT_VERBOSITY=0], [DEFAULT_VERBOSITY=1])
AC_SUBST([DEFAULT_VERBOSITY])

AC_ARG_ENABLE([additional-mods],
  [AS_HELP_STRING([--enable-additional-mods],
     [enable usage of additional modules  @<:@default: yes@:>@])],
  [], [enable_additional_mods=yes])
AS_VAR_IF([enable_additional_mods], [yes],
  [AS_VAR_APPEND([config_FCFLAGS],
     [" ${mkh_cv_fc_macro_flag}INCLUDE_MODULES"])])

AC_ARG_ENABLE([openmp],
  [AS_HELP_STRING([--enable-openmp],
     [enable OpenMP support @<:@default: yes@:>@])],
  [], [enable_openmp=yes])
AS_VAR_IF([enable_openmp], [yes],
  [MKH_LANG_OPENMP_FLAG(
     [AS_VAR_APPEND([FCFLAGS], [" $mkh_cv_fc_openmp_flag"])
      MKH_LANG_MACRO_CHECK_VALUE([_OPENMP],
        [202111 202011 201811 201511 201307 201107 200805 200505 200011 dnl
199911 199710])
      AS_VAR_IF([mkh_macro_value], [unknown],
        [AC_MSG_FAILURE([unable to detect the value of the Fortran dnl
preprocessor macro _OPENMP])],
        [AS_VAR_APPEND([DEPGEN_FCFLAGS],
           [" ${mkh_cv_fc_macro_flag}_OPENMP=$mkh_macro_value"])])])],
  [MKH_LANG_MACRO_CHECK_DEFINED([_OPENMP])
   AS_VAR_IF([mkh_macro_defined], [yes],
     [AC_MSG_ERROR([Fortran compiler enables OpenMP support by default: set dnl
FCFLAGS accordingly to disable it])])])

AC_ARG_ENABLE([module-nature-test],
  [AS_HELP_STRING([--enable-module-nature-test],
     [enable the test of special treatment for intrinsic Fortran modules, ]dnl
[which might fail for some compilers @<:@default: yes@:>@])],
  [], [enable_module_nature_test=yes])
AS_VAR_IF([enable_module_nature_test], [yes],
  [AS_VAR_APPEND([config_FCFLAGS],
     [" ${mkh_cv_fc_macro_flag}TEST_MODULE_NATURE"])])

AC_ARG_ENABLE([invalid-test],
  [AS_HELP_STRING([--enable-invalid-test],
     [enable the test for invalid dependency tree, which fails the building ]dnl
[@<:@default: no@:>@])],
  [], [enable_invalid_test=no])
AS_VAR_IF([enable_invalid_test], [yes],
  [AS_VAR_APPEND([config_FCFLAGS],
     [" ${mkh_cv_fc_macro_flag}TEST_INVALID"])
   AC_SUBST([INVALID_DISABLED], ['#'])],
  [AC_SUBST([INVALID_DISABLED], [''])])

mkhelper_linker_flags="'-L'"
AS_VAR_IF([enable_rpaths], [yes],
  [AS_VAR_APPEND([mkhelper_linker_flags], [" '$mkh_cv_fc_rpath_flag'"])])
eval "set dummy $mkhelper_linker_flags; shift"
MKH_LANG_PACKAGE_INIT([NetCDF], [$mkh_cv_fc_ftn_include_flag], ["$@"])
mkh_NETCDF_found=no
mkh_save_FCFLAGS=$FCFLAGS
NETCDF_FCFLAGS=${NETCDF_FCFLAGS-$mkh_fc_NetCDF_inc_search_args}
FCFLAGS="$NETCDF_FCFLAGS $FCFLAGS"
MKH_FC_INCLUDE_CHECK([netcdf.inc],
  [MKH_LANG_LIB_SEARCH([NETCDF_FCLIBS], [nf_open],
     [MKH_PREPEND_LDFLAGS([$mkh_fc_NetCDF_lib_search_args], [-lnetcdff])],
     [NETCDF_FCLIBS=$mkh_cv_fc_lib_func_NF_OPEN
      mkh_NETCDF_found=yes], [:])], [:])
FCFLAGS=$mkh_save_FCFLAGS
AS_VAR_IF([mkh_NETCDF_found], [no],
  [AS_VAR_APPEND([config_FCFLAGS], [" ${mkh_cv_fc_macro_flag}NO_NETCDF"])
   NETCDF_FCFLAGS=;NETCDF_FCLIBS=])

AC_MSG_CHECKING([for names of the polymorphic example options])
AS_IF([test -n "$mkh_examples"],
  [mkh_seen_example_options=
   for mkh_option in $mkh_examples; do
     MKH_VAR_APPEND_UNIQ([mkh_seen_example_options], [$mkh_option], [','])
   done
   AC_MSG_RESULT([$mkh_seen_example_options])
   mkh_save_IFS=$IFS
   IFS=','
   for mkh_option in $mkh_seen_example_options; do
     IFS=$mkh_save_IFS
     AC_MSG_NOTICE([$mkh_option: AS_VAR_GET([enable_example_$mkh_option])])
   done
   IFS=$mkh_save_IFS],
  [AC_MSG_RESULT([none provided])])

AC_ARG_VAR([AR], [the archiver command])dnl
AC_ARG_VAR([ARFLAGS], [archiver flags])dnl
ARFLAGS=${ARFLAGS-cr}
MKH_PROG_SEARCH([AR], [ar],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [])],
     [mkhelper_ar_try="$mkh_candidate ${ARFLAGS} libconftest.a dnl
conftest.$ac_objext >&AS_MESSAGE_LOG_FD"
      _AC_DO_VAR([mkhelper_ar_try])
      rm -f libconftest.a])
   test "$ac_status" -eq 0 >/dev/null 2>&1],
  [AR=$mkh_cv_prog_AR])

AC_ARG_VAR([PYTHON],
  [Python interpreter command (used for Fortran dependency generation)])dnl
MKH_PROG_SEARCH([PYTHON], [python python3],
  [mkhelper_depgen_try='$mkh_candidate dnl
$srcdir/mkhelper/depgen.py -h > /dev/null'
   AC_TRY_EVAL([mkhelper_depgen_try])],
  [PYTHON=$mkh_cv_prog_PYTHON])

AC_PROG_INSTALL
AC_PROG_MKDIR_P

mkhelper_some_prog='true -a -b -c'
MKH_PROG_SEARCH_ABSPATH_IF_NOT_ABSPATH([mkhelper_some_prog])

dnl A list of flags enabling location of the include files of the enabled
dnl bundled libraries:
AC_SUBST([BUNDLED_FCFLAGS], [''])

dnl A list of library files (i.e. *.a files) of the enabled bundled libraries:
AC_SUBST([BUNDLED_LIBFILES], [''])

dnl Configure a bundled library that is very picky on the provided configure
dnl options:
polymorphic_subdir='bundled/picky'
polymorphic_config=''
MKH_SUBDIR_INIT_CONFIG([$polymorphic_subdir],
  [no-run no-recursive-help], [], [AS_ESCAPE(["${polymorphic_config}"])])
polymorphic_subdir=
polymorphic_config='configure.gnu'
MKH_SUBDIR_REMOVE_ARGS([bundled/picky],
  [FCFLAGS=*],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([silent-rules])],
  [MKH_SUBDIR_CONFIG_PATTERN_WITH([netcdf-root])],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([always])])
MKH_SUBDIR_APPEND_ARGS_UNQUOTED([bundled/picky],
  [" 'FCFLAGS='"], [" '--enable-always=yes'"])dnl

AC_ARG_ENABLE([delayed-config],
  [AS_HELP_STRING([--enable-delayed-config],
     [enable the delayed (build-time) configuration of the bundled/picky ]dnl
[and bundled/cmake_based subdirectories @<:@default: yes@:>@])],
  [AS_IF([test x"$enableval" != xno], [enable_delayed_config=yes])],
  [enable_delayed_config=yes])

AC_SUBST([DELAYED_CONFIG_RULES], [''])dnl
AS_VAR_IF([enable_delayed_config], [yes],
  [AS_VAR_APPEND([DELAYED_CONFIG_RULES],
     ["export FC${as_nl}polymorphic_config:= $polymorphic_config${as_nl}"])],
  [polymorphic_subdir='bundled/picky'
   MKH_SUBDIR_RUN_RESET([$polymorphic_subdir], [yes])
   MKH_SUBDIR_RUN_EXTRA([$polymorphic_subdir],
     [echo "Run before 1"],
     [echo "Run after 1"])
   polymorphic_subdir=

   MKH_SUBDIR_RUN_EXTRA([bundled/picky], [echo "Run before 2"])
   MKH_SUBDIR_RUN_EXTRA([bundled/picky], [], [echo "Run after 2"])])

dnl Configure a libtool-based bundled library that depends on POSIX Threads:
MKH_SUBDIR_INIT_CONFIG([bundled/threaded_hello],
  [], [bundled/build/threaded_hello])
MKH_SUBDIR_REMOVE_ARGS([bundled/build/threaded_hello],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([static])],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([shared])],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([maintainer-mode])],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([silent-rules])])
MKH_SUBDIR_APPEND_ARGS([bundled/build/threaded_hello],
  [--enable-static --disable-shared --disable-maintainer-mode],
  [--enable-silent-rules="$enable_silent_rules"])
AS_VAR_APPEND([BUNDLED_FCFLAGS], ["${FC_MOD_IN}bundled/build/threaded_hello "])
BUNDLED_LIBFILES="bundled/build/threaded_hello/.libs/libthreaded_hello_f.a dnl
$BUNDLED_LIBFILES"
MKH_SUBDIR_INIT_IFELSE([bundled/build/threaded_hello],
  [AS_VAR_APPEND([DEPGEN_EXTERNAL_MODS], [',mo_threaded_hello'])])

dnl Initialize a bundled library that will be configured at the build time:
MKH_SUBDIR_INIT_CONFIG([bundled/delayed], [no-run], [bundled/build/delayed])
MKH_SUBDIR_REMOVE_ARGS([bundled/build/delayed],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([silent-rules])])
MKH_SUBDIR_APPEND_ARGS([bundled/build/delayed],
  [--enable-silent-rules="$enable_silent_rules"])
AS_VAR_APPEND([BUNDLED_FCFLAGS], ["${FC_MOD_IN}bundled/build/delayed "])
BUNDLED_LIBFILES="bundled/build/delayed/libdelayed.a $BUNDLED_LIBFILES"
MKH_SUBDIR_INIT_IFELSE([bundled/build/delayed],
  [AS_VAR_APPEND([DEPGEN_EXTERNAL_MODS], [',mo_delayed'])])

dnl Initialize another bundled library from the same source directory:
MKH_SUBDIR_INIT_CONFIG([bundled/delayed], [no-run],
  [bundled/build/delayed_mangled])
MKH_SUBDIR_REMOVE_ARGS([bundled/build/delayed_mangled],
  [CPPFLAGS=*],
  [MKH_SUBDIR_CONFIG_PATTERN_ENABLE([silent-rules])])
MKH_SUBDIR_APPEND_ARGS([bundled/build/delayed_mangled],
  [CPPFLAGS="${mkh_cv_fc_macro_flag}MANGLE"],
  [--enable-silent-rules="$enable_silent_rules"])
AS_VAR_APPEND([BUNDLED_FCFLAGS], ["${FC_MOD_IN}bundled/build/delayed_mangled "])
BUNDLED_LIBFILES="bundled/build/delayed_mangled/libdelayed.a $BUNDLED_LIBFILES"
MKH_SUBDIR_INIT_IFELSE([bundled/build/delayed_mangled],
  [AS_VAR_APPEND([DEPGEN_EXTERNAL_MODS], [',mo_delayed_mangled'])])

dnl Initialize a CMake-based library:
AC_SUBST([CMAKE], [${CMAKE-cmake}])dnl
MKH_SUBDIR_INIT_CMAKE(
  [bundled/cmake_based], [no-run], [bundled/cmake_based/build],
  [AS_ESCAPE(["${CMAKE}"])])
dnl By default, set non-existing build type to avoid extra compiler flags:
MKH_SUBDIR_DEFAULT_ARGS_UNQUOTED([bundled/cmake_based/build],
  [" '-DCMAKE_BUILD_TYPE=NOEXTRAFLAGS'"])dnl
MKH_SUBDIR_APPEND_ARGS([bundled/cmake_based/build],
  [-DBUILD_SHARED_LIBS:BOOL=OFF])
AS_VAR_APPEND([BUNDLED_FCFLAGS], ["${FC_MOD_IN}bundled/cmake_based/build/mod "])
BUNDLED_LIBFILES=dnl
"bundled/cmake_based/build/libCMakeBasedHello.a $BUNDLED_LIBFILES"
MKH_SUBDIR_INIT_IFELSE([bundled/cmake_based/build],
  [AS_VAR_APPEND([DEPGEN_EXTERNAL_MODS], [',mo_cmake_based'])])
AS_VAR_IF([enable_delayed_config], [no],
  [MKH_SUBDIR_RUN_RESET([bundled/cmake_based], [yes])])

AC_SUBST([bundled_ready_config_subdirs], [''])dnl
AC_SUBST([bundled_delayed_config_subdirs], [''])dnl
AC_SUBST([bundled_ready_cmake_subdirs], [''])dnl
AC_SUBST([bundled_delayed_cmake_subdirs], [''])dnl
mkhelper_rule_separator=''
for mkhelper_build_subdir in $extra_build_subdirs; do
  MKH_SUBDIR_GET_BUILD_TYPE([mkhelper_build_type], [$mkhelper_build_subdir])
  MKH_SUBDIR_RUN_IFELSE([$mkhelper_build_subdir],
    [AS_VAR_APPEND([bundled_ready_${mkhelper_build_type}_subdirs],
       [" $mkhelper_build_subdir"])],
    [AS_VAR_APPEND([bundled_delayed_${mkhelper_build_type}_subdirs],
       [" $mkhelper_build_subdir"])
     MKH_SUBDIR_GET_RUN_CMD([mkhelper_subdir_cmd], [$mkhelper_build_subdir])
     AS_VAR_IF([mkhelper_build_type], [cmake],
       [mkhelper_silent_var='silent_CMAKE'
        mkhelper_silent_suffix='>/dev/null'],
       [mkhelper_silent_var='silent_CONFIG'
        mkhelper_silent_suffix='--silent'])
     AS_VAR_APPEND([DELAYED_CONFIG_RULES], [dnl
"$mkhelper_rule_separator$mkhelper_build_subdir: dnl
\$(if \$(filter-out mostlyclean clean distclean,\$(or \$(MAKECMDGOALS),all)),dnl
$mkhelper_build_subdir/Makefile)
$mkhelper_build_subdir/Makefile:
	\$($mkhelper_silent_var)$MKDIR_P \$(@D) && cd \$(@D) && dnl
$mkhelper_subdir_cmd \$(if \$($mkhelper_silent_var),$mkhelper_silent_suffix)"])
	 mkhelper_rule_separator="$as_nl$as_nl"])
done

dnl Collect compiler and linker flags required for linking to the library:
AC_CONFIG_COMMANDS_PRE(
  [MKH_SUBDIR_QUERY_CONFIG_STATUS([mkhelper_LDFLAGS],
     [bundled/build/threaded_hello], [@LDFLAGS@])
   MKH_SUBDIR_QUERY_CONFIG_STATUS([mkhelper_LIBS],
     [bundled/build/threaded_hello], [@LIBS@])
   AS_IF([test -n "$mkhelper_LDFLAGS"],
     [AS_VAR_APPEND([LDFLAGS], [" $mkhelper_LDFLAGS"])])
   AS_IF([test -n "$mkhelper_LDFLAGS"], [LIBS="$mkhelper_LIBS $LIBS"])
dnl Except for RPATH flags:
   AS_VAR_IF([enable_rpaths], [yes],
     [MKH_EXTRACT_ARGS([mkhelper_libdirs],
        ["$mkhelper_LDFLAGS $mkhelper_LIBS"], ['-L@<:@ @:>@*'])
      for mkhelper_libdir in $mkhelper_libdirs; do
        AS_IF([test -d "$mkhelper_libdir"],
          [MKH_VAR_APPEND_UNIQ([LDFLAGS],
             ["$mkh_cv_fc_rpath_flag$mkhelper_libdir"], [' '])])
      done])
dnl We need to link to pthread library, which might require PTHREAD_CFLAGS
   MKH_SUBDIR_QUERY_CONFIG_STATUS([mkhelper_PTHREAD_CFLAGS],
     [bundled/build/threaded_hello], [' @PTHREAD_CFLAGS@'])
   AS_IF([test -n "$mkhelper_PTHREAD_CFLAGS"],
     [AS_VAR_IF([FC_VENDOR], [nag],
        [mkhelper_PTHREAD_CFLAGS=`AS_ECHO([" $mkhelper_PTHREAD_CFLAGS"]) | dnl
sed 's/ -pthread/ -Wl,-pthread/g'`])
      AS_VAR_APPEND([LDFLAGS], ["$mkhelper_PTHREAD_CFLAGS"])])])

AC_CONFIG_FILES([
  Makefile
  depgen.config
  deplist.config
  mkhelper.mk
])

AC_CONFIG_COMMANDS([depfiles],
  [${MAKE-make} -f mkhelper.mk dummy-depend >/dev/null 2>&AS_MESSAGE_LOG_FD
   sleep 1
   touch mkhelper.mk])

AC_OUTPUT
