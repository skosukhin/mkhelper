AC_INIT([mkhelper], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_SRCDIR([src/program/main.f90])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])

AC_CONFIG_FILES([Makefile depgen.config])

AC_PROG_FC
AC_LANG([Fortran])
AC_FC_PP_SRCEXT([f90])
AC_FC_FREEFORM
AC_FC_LINE_LENGTH([unlimited])

AC_SUBST([DEPGEN_DEFS])
AC_SUBST([DEPGEN_INTRINSIC_MODS],
  [[iso_c_binding,iso_fortran_env,ieee_exceptions,ieee_arithmetic,ieee_features,omp_lib,omp_lib_kinds,openacc]])
AC_SUBST([DEPGEN_EXTERNAL_MODS])

ACX_FC_VENDOR

ACX_FC_MACRO_DEFINE([AC_SUBST([FC_PP_DEF], [$acx_cv_fc_macro_define])])
ACX_FC_MOD_SEARCH_FLAG([AC_SUBST([FC_MOD_IN], [$acx_cv_fc_mod_search_flag])])
ACX_FC_MOD_OUTPUT_FLAG([AC_SUBST([FC_MOD_OUT], [$acx_cv_fc_mod_output_flag])])

ACX_FC_MOD_OUTPUT_NAME(
  [AC_SUBST([FC_MOD_FILE_UPPER], [$acx_cv_fc_mod_output_name_upper])
   AC_SUBST([FC_MOD_FILE_EXT], [$acx_cv_fc_mod_output_name_ext])])

ACX_FC_INC_SEARCH_FLAG([fc], [AC_SUBST([FC_INC_FLAG], [$acx_cv_fc_inc_search_flag_fc])])
ACX_FC_INC_SEARCH_ORDER([fc],
  [${acx_cv_fc_inc_search_flag_fc}],
  [FC_INC_ORDER=$acx_cv_fc_inc_search_order_fc],
  [FC_INC_ORDER=src,flg])
AC_SUBST([FC_INC_ORDER])

ACX_FC_INC_SEARCH_FLAG([pp], [AC_SUBST([FC_PP_INC_FLAG_f90], [$acx_cv_fc_inc_search_flag_pp])])
ACX_FC_INC_SEARCH_ORDER([pp],
  [${acx_cv_fc_inc_search_flag_pp}],
  [FC_PP_INC_ORDER_f90=$acx_cv_fc_inc_search_order_pp],
  [FC_PP_INC_ORDER_f90=inc,flg])
AC_SUBST([FC_PP_INC_ORDER_f90])

AC_ARG_ENABLE([additional-mods],
  [AC_HELP_STRING([--enable-additional-mods], [enable usage of additional modules  @<:@default: yes@:>@])],
  [], [enable_additional_mods=yes])
AS_IF([test "x$enable_additional_mods" = xyes],
  [FCFLAGS="${acx_cv_fc_macro_define}INCLUDE_MODULES $FCFLAGS"])

AC_ARG_ENABLE([openmp],
  [AS_HELP_STRING([--enable-openmp], [enable OpenMP support @<:@default: yes@:>@])],
  [], [enable_openmp=yes])
AS_IF([test "x$enable_openmp" = "xyes"],
  [ACX_OPENMP(
     [FCFLAGS="$OPENMP_FCFLAG $FCFLAGS"
      ACX_OPENMP_MACRO_VAL(
        [AS_IF([test "x$acx_cv_prog_fc_openmp_macro" = "xunknown"],
           [AS_VAR_APPEND([DEPGEN_DEFS], [" ${acx_cv_fc_macro_define}_OPENMP"])],
           [AS_VAR_APPEND([DEPGEN_DEFS], [" ${acx_cv_fc_macro_define}_OPENMP=$acx_cv_prog_fc_openmp_macro"])])])])],
  [ACX_OPENMP_CHECK_DISABLED])

AC_MSG_CHECKING([whether the Fortran interface of NetCDF library is available])
AC_LINK_IFELSE([AC_LANG_PROGRAM([], [[
      include 'netcdf.inc'
      integer ncid, status
      status = nf_open('dummy.nc', 0, ncid)]])],
  [AC_MSG_RESULT([yes])],
  [AC_MSG_RESULT([no])
  FCFLAGS="${acx_cv_fc_macro_define}NO_NETCDF $FCFLAGS"])

AC_ARG_VAR([AR], [the archiver command])
ACX_CHECK_PROGS([AR], [ar], [for the archiver command],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [])],
    [acx_ar_try='$acx_prog_candidate cru libconftest.a conftest.$ac_objext >&AS_MESSAGE_LOG_FD'
    AC_TRY_EVAL([acx_ar_try])
    rm -f libconftest.a])
  test "$ac_status" -eq 0],
  [unknown])
AS_IF([test "x$AR" = xunknown],
  [AC_MSG_FAILURE([unable to find the archiver command])])

AC_ARG_VAR([PYTHON], [Python interpreter command (used for Fortran dependency generation)])
ACX_CHECK_PROGS([PYTHON], [python python3], [for Python interpreter command],
  [acx_depgen_try='$acx_prog_candidate $srcdir/mkhelper/depgen.py -h > /dev/null'
  AC_TRY_EVAL([acx_depgen_try])],
  [unknown])
AS_IF([test "x$PYTHON" = xunknown],
  [AC_MSG_FAILURE([unable to find Python interpreter])])

AC_PROG_INSTALL

AC_OUTPUT
