# MKH_FC_MISMATCH([ACTION-IF-SUCCESS],
#                 [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the compiler flag needed to allow routines to be called with different
# argument types. The result is either "unknown", or the actual compiler flag
# required to downgrade consistency checking of procedure argument lists, which
# may be an empty string.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the mkh_cv_[]_AC_LANG_ABBREV[]_mismatch_flag variable.
#
# Known flags:
# NAGWare: -mismatch
#
AC_DEFUN([MKH_FC_MISMATCH],
  [_AC_FORTRAN_ASSERT()dnl
   m4_pushdef([mkh_cache_var], [mkh_cv_[]_AC_LANG_ABBREV[]_mismatch_flag])dnl
   AC_MSG_CHECKING([for _AC_LANG compiler flag needed to allow routines to dnl
be called with different argument types])
   AC_CACHE_VAL([mkh_cache_var],
     [mkh_cache_var=unknown
      mkh_save_[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
      AC_LANG_CONFTEST([AC_LANG_PROGRAM([], [[      implicit none
      integer a
      real b
      character c
      call foo1(a)
      call foo1(b)
      call foo1(c)]])])
      for mkh_flag in '' -mismatch; do
        _AC_LANG_PREFIX[]FLAGS="${mkh_save_[]_AC_LANG_PREFIX[]FLAGS} $mkh_flag"
        AC_COMPILE_IFELSE([], [mkh_cache_var=$mkh_flag])
        test "x$mkh_cache_var" != xunknown && break
      done
      rm -f conftest.$ac_ext
      _AC_LANG_PREFIX[]FLAGS=$mkh_save_[]_AC_LANG_PREFIX[]FLAGS])
   AS_IF([test -n "$mkh_cache_var"],
     [AC_MSG_RESULT([$mkh_cache_var])],
     [AC_MSG_RESULT([none needed])])
   AS_VAR_IF([mkh_cache_var], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect _AC_LANG compiler flag needed to dnl
allow routines to be called with different argument types])])], [$1])
   m4_popdef([mkh_cache_var])])
