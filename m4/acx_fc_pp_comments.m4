# ACX_FC_PP_COMMENTS([ACTION-IF-SUCCESS],
#                    [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler handles C-style block comments as well as
# single line in the context of macro definitions. The result is either "yes"
# or "no".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_pp_comments.
#
AC_DEFUN([ACX_FC_PP_COMMENTS],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_PROVIDE_IFELSE([AC_FC_PP_SRCEXT], [],
     [m4_warn([syntax],
        [ACX_FC_PP_COMMENTS requires calling the Fortran compiler with a ]dnl
[preprocessor but no call to AC_FC_PP_SRCEXT is detected])])dnl
   AC_CACHE_CHECK([whether Fortran compiler supports C-style comments],
     [acx_cv_fc_pp_comments],
     [acx_cv_fc_pp_comments=no
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([],
[[/* block
comment */
#define CONFTEST_MACRO1 // single line comment
#define CONFTEST_MACRO2 /* block comment */
#ifndef CONFTEST_MACRO1
      choke me
#endif
#ifndef CONFTEST_MACRO2
      choke me
#endif]])],
        [acx_cv_fc_pp_comments=yes])])
   AS_VAR_IF([acx_cv_fc_pp_comments], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE(
           [Fortran compiler does not support C-style comments])])])])
