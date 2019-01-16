# ACX_LANG_OPENMP_FLAG([ACTION-IF-SUCCESS],
#                      [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Originally taken from the master branch of Autoconf where it is a part of
# AC_OPENMP.
# ---------------------------------------------------------------------
# Finds the compiler flag needed to enable OpenMP support. The result is either
# "unknown", or the actual compiler flag required to enable OpenMP support,
# which may be an empty string.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_[]_AC_LANG_ABBREV[]_openmp_flag variable.
#
# Known flags:
# Intel >= 16: -qopenmp
# NAG, Intel < 16: -openmp
# GNU: -fopenmp
# Cray: -homp
# SGI, PGI: -mp
# SunPRO: -xopenmp
# Tru64 Compaq C: -omp
# IBM XL: -qsmp=omp
# NEC SX: -Popenmp
# Lahey Fortran: --openmp
#
AC_DEFUN([ACX_LANG_OPENMP_FLAG],
  [m4_pushdef([acx_cache_var], [acx_cv_[]_AC_LANG_ABBREV[]_openmp_flag])dnl
   AC_MSG_CHECKING([for _AC_LANG compiler flag needed to enable OpenMP dnl
support])
   AS_VAR_SET_IF([acx_cache_var],
     [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
     [acx_cache_var=unknown
      acx_save_[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
      AC_LANG_CONFTEST([_AC_LANG_OPENMP])
      for acx_lang_openmp_flag in '' -qopenmp -openmp -fopenmp -homp -mp dnl
-xopenmp -omp -qsmp=omp -Popenmp --openmp; do
        _AC_LANG_PREFIX[]FLAGS="${acx_save_[]_AC_LANG_PREFIX[]FLAGS} dnl
$acx_lang_openmp_flag"
        AC_LINK_IFELSE([],
          [acx_cache_var=$acx_lang_openmp_flag
           break])
      done
      _AC_LANG_PREFIX[]FLAGS=$acx_save_[]_AC_LANG_PREFIX[]FLAGS])
   AS_IF([test -n "$acx_cache_var"],
     [AC_MSG_RESULT([$acx_cache_var])],
     [AC_MSG_RESULT([none needed])])
   AS_VAR_IF([acx_cache_var], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect _AC_LANG compiler flag needed to dnl
enable OpenMP support])])], [$1])])