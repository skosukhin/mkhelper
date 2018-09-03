AC_INIT([mkhelper], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_MACRO_DIR([m4])

AC_PREFIX_DEFAULT([$(pwd)/bin])

AC_PROG_FC
AC_LANG([Fortran])
AC_FC_PP_SRCEXT(f90)
AC_FC_FREEFORM

ACX_FC_PP_DEFINE
ACX_FC_MODULE_INC_FLAG
ACX_FC_MODULE_OUT_FLAG

ACX_FC_MODULE_FILE_NAMING(
[FORTDEP_MODULE_FILE_UPPER=$acx_cv_fc_module_file_naming_upper
FORTDEP_MODULE_FILE_EXT=$acx_cv_fc_module_file_naming_ext],
[FORTDEP_MODULE_FILE_UPPER=no
FORTDEP_MODULE_FILE_EXT=mod])
AC_SUBST([FORTDEP_MODULE_FILE_UPPER])
AC_SUBST([FORTDEP_MODULE_FILE_EXT])

ACX_FC_INCLUDE_ORDER(
[FORTDEP_INC_ORDER=$acx_cv_fc_include_order],
[FORTDEP_INC_ORDER=src,flg])
AC_SUBST([FORTDEP_INC_ORDER])

ACX_FC_HASH_INCLUDE_ORDER(
[FORTDEP_INC_PP_ORDER=$acx_cv_fc_hash_include_order],
[FORTDEP_INC_PP_ORDER=inc,flg])
AC_SUBST([FORTDEP_INC_PP_ORDER])

AC_ARG_VAR([AR], [the archiver command (used to create convenience libraries)])
ACX_CHECK_AR([AR], [ar], [unknown])
AS_IF([test "x$AR" = xunknown],
  [AC_MSG_ERROR([unable to find the archiver command])])

AC_ARG_VAR([PYTHON], [Python interpreter command (used for Fortran dependency generation)])
ACX_CHECK_PROGS([PYTHON], [python python3], [for Python interpreter command],
  [acx_fortdep_try='$acx_prog_candidate $srcdir/mkhelper/fortdep/generator --help > /dev/null && $acx_prog_candidate $srcdir/mkhelper/fortdep/collector --help > /dev/null'
  AC_TRY_EVAL([acx_fortdep_try])],
  [unknown])
AS_IF([test "x$PYTHON" = xunknown],
  [AC_MSG_ERROR([unable to find Python interpreter])])

AC_SUBST([FC_DEFINITIONS])

AC_ARG_ENABLE([additional-mods],
  [AC_HELP_STRING([--enable-additional-mods], [enable usage of additional modules  @<:@default: yes @>:@])],
  [],
  [enable_additional_mods=yes])

AS_IF([test x"$enable_additional_mods" = xyes],
  AS_VAR_APPEND([FC_DEFINITIONS], [" ${FC_DEFINE}INCLUDE_MODULES"]))

AC_LANG_PUSH([Fortran])
AC_MSG_CHECKING([whether the Fortran interface of NetCDF library is available])
AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'netcdf.inc'
      integer ncid, status
      status = nf_open('dummy.nc', 0, ncid)]])],
  [AC_MSG_RESULT([yes])],
  [AC_MSG_RESULT([no])
  AS_VAR_APPEND([FC_DEFINITIONS], [" ${FC_DEFINE}NO_NETCDF"])])
AC_LANG_POP([Fortran])

AC_CONFIG_FILES(Makefile)
AC_OUTPUT
