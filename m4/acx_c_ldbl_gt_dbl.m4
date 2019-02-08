# ACX_C_LDBL_GT_DBL([ACTION-IF-SUCCESS],
#                   [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether C "long double" offers more precision and greater range than
# "double".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_c_ldbl_gt_dbl variable.
#
AC_DEFUN([ACX_C_LDBL_GT_DBL],
  [AC_LANG_ASSERT([C])dnl
   AC_CACHE_CHECK([whether C "long double" differs from "double"],
     [acx_cv_c_ldbl_gt_dbl],
     [AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
[[#include <float.h>
#if !((LDBL_MAX_EXP > DBL_MAX_EXP) && (LDBL_MANT_DIG > DBL_MANT_DIG))
choke me
#endif]])],
        [acx_cv_c_ldbl_gt_dbl=yes],
        [acx_cv_c_ldbl_gt_dbl=no])])
   AS_VAR_IF([acx_cv_c_ldbl_gt_dbl], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([C "long double" does not have higher precision dnl
and/or greater range than "double"])])])])
