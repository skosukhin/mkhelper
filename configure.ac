AC_INIT([mkhelper], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_SRCDIR([src/program/main.f90])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AC_CONFIG_FILES([Makefile depgen.config])

AC_PREFIX_DEFAULT(["`pwd`/install"])

AC_CANONICAL_HOST

ACX_BUILD_ENVIRONMENT

AC_ARG_ENABLE([rpaths],
  [AC_HELP_STRING([--enable-rpaths],
     [prepend LDFLAGS with additional linker flags to add directories specified
with -L flags to the runtime library search path (RPATH)
@<:@default=yes@:>@])], [],
  [enable_rpaths=yes])

ACX_COMPILER_CROSS_CHECK_DELAY
AC_PROG_FC
AC_LANG([Fortran])
AC_FC_PP_SRCEXT([f90])

AS_VAR_IF([enable_rpaths], [yes],
  [ACX_SHLIB_FC_RPATH_FLAG
   ACX_SHLIB_PATH_VAR
   eval link_cmd="\"$ac_link\""
   ASX_EXTRACT_ARGS([mkhelper_libdirs], [`echo $link_cmd`], ['-L@<:@ @:>@*'])
   mkhelper_rpath_flags=
   for mkhelper_libdir in $mkhelper_libdirs; do
     AS_IF([test -d "$mkhelper_libdir"],
       [ASX_VAR_APPEND_UNIQ([mkhelper_rpath_flags],
          ["$acx_cv_fc_rpath_flag$mkhelper_libdir"], [' '])
        ASX_VAR_APPEND_UNIQ([$acx_cv_shlib_path_var],
          ["$mkhelper_libdir"], [':'])])
   done
   AS_IF([test -n "$mkhelper_rpath_flags"],
     [ACX_SHLIB_RPATH_FLAGS_CHECK([$mkhelper_rpath_flags],
        [LDFLAGS="$mkhelper_rpath_flags $LDFLAGS"])])
   eval export $acx_cv_shlib_path_var])

ACX_COMPILER_CROSS_CHECK_NOW
AC_FC_LINE_LENGTH([unlimited])

AC_SUBST([DEPGEN_DEFS])
AC_SUBST([DEPGEN_INTRINSIC_MODS],
  [[iso_c_binding,iso_fortran_env,ieee_exceptions,ieee_arithmetic,]dnl
[ieee_features,omp_lib,omp_lib_kinds,openacc]])
AC_SUBST([DEPGEN_EXTERNAL_MODS])

ACX_FC_MODULE_IN_FLAG([AC_SUBST([FC_MOD_IN], [$acx_cv_fc_module_in_flag])])
ACX_FC_MODULE_OUT_FLAG([AC_SUBST([FC_MOD_OUT], [$acx_cv_fc_module_out_flag])])

ACX_FC_MODULE_NAMING(
  [AC_SUBST([FC_MOD_FILE_UPPER], [$acx_cv_fc_module_naming_upper])
   AC_SUBST([FC_MOD_FILE_EXT], [$acx_cv_fc_module_naming_ext])])

ACX_FC_INCLUDE_FLAG(
  [AC_SUBST([FC_INC_FLAG], [$acx_cv_fc_ftn_include_flag])])
ACX_FC_INCLUDE_ORDER(
  [FC_INC_ORDER=$acx_cv_fc_ftn_include_order],
  [FC_INC_ORDER=src,flg])
AC_SUBST([FC_INC_ORDER])

ACX_FC_INCLUDE_FLAG_PP(
  [AC_SUBST([FC_INC_FLAG_PP_f90], [$acx_cv_fc_pp_include_flag])])
ACX_FC_INCLUDE_ORDER_PP(
  [FC_INC_ORDER_PP_f90=$acx_cv_fc_pp_include_order],
  [FC_INC_ORDER_PP_f90=inc,flg])
AC_SUBST([FC_INC_ORDER_PP_f90])

ACX_LANG_MACRO_FLAG([AC_SUBST([FC_PP_DEF], [$acx_cv_fc_macro_flag])])

AC_SUBST([config_FCFLAGS])

AC_ARG_ENABLE([silent-rules],
  [AC_HELP_STRING([--enable-silent-rules],
     [less verbose build output (undo: "make V=1") @<:@default=yes@:>@])], [],
  [enable_silent_rules=yes])
AS_VAR_IF([enable_silent_rules], [yes],
  [DEFAULT_VERBOSITY=0], [DEFAULT_VERBOSITY=1])
AC_SUBST([DEFAULT_VERBOSITY])

AC_ARG_ENABLE([additional-mods],
  [AC_HELP_STRING([--enable-additional-mods],
     [enable usage of additional modules  @<:@default: yes@:>@])],
  [], [enable_additional_mods=yes])
AS_VAR_IF([enable_additional_mods], [yes],
  [AS_VAR_APPEND([config_FCFLAGS], [" ${acx_cv_fc_macro_flag}INCLUDE_MODULES"])])

AC_ARG_ENABLE([openmp],
  [AC_HELP_STRING([--enable-openmp],
     [enable OpenMP support @<:@default: yes@:>@])],
  [], [enable_openmp=yes])
AS_VAR_IF([enable_openmp], [yes],
  [ACX_LANG_OPENMP_FLAG(
     [AS_VAR_APPEND([FCFLAGS], [" $acx_cv_fc_openmp_flag"])
      ACX_LANG_MACRO_CHECK_VALUE([_OPENMP],
        [201511 201307 201107 200805 200505 200011 199911 199710])
      AS_VAR_IF([acx_macro_value], [unknown],
        [AC_MSG_FAILURE([unable to detect the value of the Fortran dnl
preprocessor macro _OPENMP])],
        [AS_VAR_APPEND([DEPGEN_DEFS],
           [" ${acx_cv_fc_macro_flag}_OPENMP=$acx_macro_value"])])])],
  [ACX_LANG_MACRO_CHECK_DEFINED([_OPENMP])
   AS_VAR_IF([acx_macro_defined], [yes],
     [AC_MSG_ERROR([Fortran compiler enables OpenMP support by default: set dnl
FCFLAGS accordingly to disable it])])])

AC_ARG_ENABLE([module-nature-test],
  [AC_HELP_STRING([--enable-module-nature-test],
     [enable the test of special treatment for intrinsic Fortran modules, ]dnl
[which might fail for some compilers @<:@default: yes@:>@])],
  [], [enable_module_nature_test=yes])
AS_VAR_IF([enable_module_nature_test], [yes],
  [AS_VAR_APPEND([config_FCFLAGS],
     [" ${acx_cv_fc_macro_flag}TEST_MODULE_NATURE"])])

ACX_LANG_PACKAGE_INIT([NetCDF],
  [$acx_cv_fc_ftn_include_flag],
  [-L "$acx_cv_fc_rpath_flag"])
acx_NETCDF_found=no
acx_save_FCFLAGS=$FCFLAGS
NETCDF_FCFLAGS=${NETCDF_FCFLAGS-$acx_fc_NetCDF_inc_search_args}
FCFLAGS="$NETCDF_FCFLAGS $FCFLAGS"
ACX_FC_INCLUDE_CHECK([netcdf.inc],
  [ACX_LANG_LIB_SEARCH([NETCDF_FCLIBS], [nf_open],
     [ASX_PREPEND_LDFLAGS([$acx_fc_NetCDF_lib_search_args], [-lnetcdff])],
     [NETCDF_FCLIBS=$acx_cv_fc_lib_func_NF_OPEN
      acx_NETCDF_found=yes], [:])], [:])
FCFLAGS=$acx_save_FCFLAGS
AS_VAR_IF([acx_NETCDF_found], [no],
  [AS_VAR_APPEND([config_FCFLAGS], [" ${acx_cv_fc_macro_flag}NO_NETCDF"])
   NETCDF_FCFLAGS=;NETCDF_FCLIBS=])

AC_ARG_VAR([AR], [the archiver command])dnl
ACX_PROG_SEARCH([AR], [ar],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [])],
     [acx_ar_try='$acx_candidate cru libconftest.a conftest.$ac_objext dnl
>&AS_MESSAGE_LOG_FD'
      AC_TRY_EVAL([acx_ar_try])
      rm -f libconftest.a])
   test "$ac_status" -eq 0],
  [AR=$acx_candidate])

AC_ARG_VAR([PYTHON],
  [Python interpreter command (used for Fortran dependency generation)])dnl
ACX_PROG_SEARCH([PYTHON], [python python3],
  [acx_depgen_try='$acx_candidate $srcdir/mkhelper/depgen.py -h > /dev/null'
   AC_TRY_EVAL([acx_depgen_try])],
  [PYTHON=$acx_candidate])

AC_PROG_INSTALL
AC_PROG_MKDIR_P

ACX_CONFIG_SUBDIR([dummy_subdir],
  [[FCFLAGS=*|CFLAGS=*],
   [ACX_CONFIG_SUBDIR_PATTERN_ENABLE([silent-rules])],
   [ACX_CONFIG_SUBDIR_PATTERN_WITH([netcdf-root])],
   [ACX_CONFIG_SUBDIR_PATTERN_ENABLE([always])]],
  [[FCFLAGS=], [CFLAGS='-g'],
   [--enable-always=yes]])

AC_OUTPUT
