# ACX_FC_PP_INCLUDE_FLAG([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Find a flag to specify search paths for "#include" directive.
# If successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise
# run ACTION-IF-FAILURE (defaults to failing with an error message).
# The flag is cached in the acx_cv_fc_pp_include_flag variable.
# It may contain significant trailing whitespace.
AC_DEFUN([ACX_FC_PP_INCLUDE_FLAG],
  [AC_CACHE_CHECK([[for Fortran flag to specify search paths for the "#include" directive]], [acx_cv_fc_pp_include_flag],
     [_ACX_FC_INCLUDE_FLAG([#include], [-I '-I ' '-WF,-I' '-Wp,-I'])
      acx_cv_fc_pp_include_flag=$_acx_fc_include_flag])
   AS_IF([test x"$acx_cv_fc_pp_include_flag" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect Fortran flag needed to specify search paths for the "#include" statement])])])])


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
      acx_cv_fc_pp_include_order=$_acx_fc_include_order])
   AS_IF([test x"$acx_cv_fc_pp_include_order" != xunknown],
     [$2],
     [m4_default(
        [$3],
        [AC_MSG_FAILURE([[unable to detect Fortran's include order of the "#include" directive]])])])])
