# ACX_FC_PP_INCLUDE_ORDER([INCLUDE-FLAG], [ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with "#include" directive.
# If successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise
# run ACTION-IF-FAILURE (defaults to failing with an error message).
# The result is cached in the acx_cv_fc_pp_include_order variable.
#
# For the description of result, see the documentation of _ACX_FC_INCLUDE_ORDER.
AC_DEFUN([ACX_FC_PP_INCLUDE_ORDER],
  [AC_CACHE_CHECK([[for Fortran's include order of the "#include" directive]], [acx_cv_fc_pp_include_order],
     [_ACX_FC_INCLUDE_ORDER([#include], [$1])
      acx_cv_fc_pp_include_order=$_acx_fc_inc_order])
   AS_IF([test x"$acx_cv_fc_pp_include_order" != xunknown],
     [$2],
     [m4_default(
        [$3],
        [AC_MSG_FAILURE([[unable to detect Fortran's include order of the "#include" directive]])])])])
