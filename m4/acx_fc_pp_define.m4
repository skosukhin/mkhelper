# ACX_FC_PP_DEFINE([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_PP_DEFINE.
# -------------------------------------------------------------------
# Find a flag to specify defines for preprocessed Fortran.  Not all
# Fortran compilers use -D. Substitute FC_DEFINE with the result and
# call ACTION-IF-SUCCESS (defaults to nothing) if successful, and
# ACTION-IF-FAILURE (defaults to failing with an error message) if not.
#
# Known flags:
# IBM: -WF,-D
# Lahey/Fujitsu: -Wp,-D     older versions???
# f2c: -D or -Wc,-D
# others: -D
AC_DEFUN([ACX_FC_PP_DEFINE],
[AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([how to define symbols for preprocessed Fortran], [acx_cv_fc_pp_define],
AC_LANG_PUSH([Fortran])
[acx_cv_fc_pp_define=unknown
acx_fc_pp_define_FCFLAGS_save=$FCFLAGS
for acx_fc_pp_define_flag in -D -WF,-D -Wp,-D -Wc,-D ; do
  FCFLAGS="$acx_fc_pp_define_FCFLAGS_save ${acx_fc_pp_define_flag}FOOBAR ${acx_fc_pp_define_flag}ZORK=42"
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#ifndef FOOBAR
      choke me
#endif
#if ZORK != 42
      choke me
#endif]])],
  [acx_cv_fc_pp_define=$acx_fc_pp_define_flag
  break])
done
FCFLAGS=$acx_fc_pp_define_FCFLAGS_save
AC_LANG_POP([Fortran])
])
AS_IF([test x"$acx_cv_fc_pp_define" != xunknown],
  [FC_DEFINE=$acx_cv_fc_pp_define
  $1],
  [FC_DEFINE=
  m4_default([$2], [AC_MSG_ERROR([Fortran does not allow to define preprocessor symbols])])])
AC_SUBST([FC_DEFINE])
])
