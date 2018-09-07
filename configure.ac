AC_INIT([mkhelper], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_SRCDIR([src/program/main.f90])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AC_CONFIG_FILES(Makefile)

AC_PROG_FC
AC_LANG([Fortran])
AC_FC_PP_SRCEXT(f90)
AC_FC_FREEFORM

ACX_FC_PP_DEFINE
ACX_FC_MODULE_INC_FLAG
ACX_FC_MODULE_OUT_FLAG

ACX_FC_MODULE_FILE_NAMING(
[FC_MODULE_UPPER=$acx_cv_fc_module_file_naming_upper
FC_MODULE_EXT=$acx_cv_fc_module_file_naming_ext],
[FC_MODULE_UPPER=no
FC_MODULE_EXT=mod])
AC_SUBST([FC_MODULE_UPPER])
AC_SUBST([FC_MODULE_EXT])

ACX_FC_INCLUDE_ORDER(
[FC_INC_ORDER=$acx_cv_fc_include_order],
[FC_INC_ORDER=src,flg])
AC_SUBST([FC_INC_ORDER])

ACX_FC_HASH_INCLUDE_ORDER(
[PP_INC_ORDER_f90=$acx_cv_fc_hash_include_order],
[PP_INC_ORDER_f90=inc,flg])
AC_SUBST([PP_INC_ORDER_f90])

AC_ARG_VAR([AR], [the archiver command])
ACX_CHECK_PROGS([AR], [ar], [for the archiver command],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [])],
    [acx_ar_try='$acx_prog_candidate cru libconftest.a conftest.$ac_objext >&AS_MESSAGE_LOG_FD'
    AC_TRY_EVAL([acx_ar_try])
    rm -f libconftest.a])
  test "$ac_status" -eq 0],
  [unknown])
AS_IF([test "x$AR" = xunknown],
  [AC_MSG_ERROR([unable to find the archiver command])])

AC_ARG_VAR([PYTHON], [Python interpreter command (used for Fortran dependency generation)])
ACX_CHECK_PROGS([PYTHON], [python python3], [for Python interpreter command],
  [acx_depgen_try='$acx_prog_candidate $srcdir/mkhelper/depgen.py -h > /dev/null'
  AC_TRY_EVAL([acx_depgen_try])],
  [unknown])
AS_IF([test "x$PYTHON" = xunknown],
  [AC_MSG_ERROR([unable to find Python interpreter])])

AC_SUBST([FC_DEFS])

AC_ARG_ENABLE([additional-mods],
  [AC_HELP_STRING([--enable-additional-mods], [enable usage of additional modules  @<:@default: yes @>:@])],
  [],
  [enable_additional_mods=yes])

AS_IF([test "x$enable_additional_mods" = xyes],
  AS_VAR_APPEND([FC_DEFS], [" ${FC_DEFINE}INCLUDE_MODULES"]))

AC_MSG_CHECKING([whether the Fortran interface of NetCDF library is available])
AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'netcdf.inc'
      integer ncid, status
      status = nf_open('dummy.nc', 0, ncid)]])],
  [AC_MSG_RESULT([yes])],
  [AC_MSG_RESULT([no])
  AS_VAR_APPEND([FC_DEFS], [" ${FC_DEFINE}NO_NETCDF"])])

AC_PROG_INSTALL

AC_OUTPUT
