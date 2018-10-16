# ACX_FC_MODULE_INC_FLAG([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# Originally taken from the master branch of autoconf where it is a part of
# AC_OPENMP.
# ---------------------------------------------------------------------
# Find a flag to enable OpenMP support. If successful, run
# ACTION-IF-SUCCESS (defaults to nothing), otherwise run
# ACTION-IF-FAILURE (defaults to failing with an error message).
# The result of the macro is cached in the
# acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp (e.g. acx_cv_prog_fc_openmp)
# variable. A successful result is either "none needed" or the actual
# compiler flag required to enable OpenMP support. A nonsuccessful
# result equals to "unsupported". The macro also creates an output
# variable OPENMP_[]_AC_LANG_PREFIX[]FLAGS (e.g. OPENMP_FCFLAGS),
# which is empty if the result is either "none needed" or
# "unsupported". The variable is set before running ACTION-IF_SUCCESS.
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
AC_DEFUN([ACX_OPENMP], [
OPENMP_[]_AC_LANG_PREFIX[]FLAGS=
AC_CACHE_CHECK([for $[]_AC_CC[] flag to enable OpenMP support],
  [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp],
  [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp="unsupported"
  acx_[]_AC_LANG_PREFIX[]FLAGS_save=$[]_AC_LANG_PREFIX[]FLAGS
  for acx_openmp_flag in '' -qopenmp -openmp -fopenmp -homp \
                         -mp -xopenmp -omp -qsmp=omp -Popenmp --openmp; do
    _AC_LANG_PREFIX[]FLAGS="$acx_[]_AC_LANG_PREFIX[]FLAGS_save $acx_openmp_flag"
    AC_LINK_IFELSE([_AC_LANG_OPENMP],
      [AS_IF([test "x$acx_openmp_flag" = "x"],
        [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp="none needed"],
        [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp=$acx_openmp_flag])
      break])
  done
  _AC_LANG_PREFIX[]FLAGS=$acx_[]_AC_LANG_PREFIX[]FLAGS_save])
AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp" != "xunsupported"],
  [AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp" != "xnone needed"],
    [OPENMP_[]_AC_LANG_PREFIX[]FLAGS=$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp])
  $1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([unable to detect flag needed to enable OpenMP support for $[]_AC_CC[]])])])
AC_SUBST([OPENMP_]_AC_LANG_PREFIX[FLAGS])
])

# ACX_OPENMP_MACRO_VAL([OPENMP-FLAGS], [ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Get the value of the preprocessor macro _OPENMP, which can be
# interpreted as a version of the OpenMP standard supported by the
# compiler. If successful, run ACTION-IF-SUCCESS (defaults to nothing),
# otherwise run ACTION-IF-FAILURE (defaults to failing with an error
# message). The result of the macro is cached in the
# acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro (e.g.
# acx_cv_prog_fc_openmp_macro). A successful result is either "unknown"
# (if _OPENMP is defined by the preprocessor but the macro was unable
# to retrieve its value) or the actual value of the preprocessor macro
# _OPENMP. A nonsuccessful result equals to "unsupported". The flag
# detected by ACX_OPENMP (e.g. OPENMP_FCFLAGS) is passed as the
# OPENMP-FLAG argument.
AC_DEFUN([ACX_OPENMP_MACRO_VAL], [
AC_CACHE_CHECK([for the value of the preprocessor macro _OPENMP set by $[]_AC_CC[]],
  [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro],
  [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro="unsupported"
  m4_ifval([$1],
    [acx_[]_AC_LANG_PREFIX[]FLAGS_save=$[]_AC_LANG_PREFIX[]FLAGS
    _AC_LANG_PREFIX[]FLAGS="$acx_[]_AC_LANG_PREFIX[]FLAGS_save $1"])
  AS_IF([test "x$cross_compiling" = "xno"],
    [AC_LINK_IFELSE([_ACX_LANG_OPENMP_MACRO],
      [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro=`./conftest$ac_exeext`
      AS_IF([test $? -ne 0],
        [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro="unsupported"])])])
  AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro" = "xunsupported"],
    [for acx_openmp_ver in 201511 201307 201107 200805 200505; do
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#if _OPENMP != $acx_openmp_ver
      choke me
#endif]])],
        [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro=$acx_openmp_ver
        break])
    done])
  AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro" = "xunsupported"],
    [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#ifndef _OPENMP
      choke me
#endif]])],
      [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro=unknown])])
  m4_ifval([$1],
    [_AC_LANG_PREFIX[]FLAGS=$acx_[]_AC_LANG_PREFIX[]FLAGS_save])])
AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_macro" != unknown],
  [$2],
  [m4_default(
    [$3],
    [AC_MSG_ERROR([the preprocessor used by $[]_AC_CC[] does not set the macro _OPENMP])])])
])

# ACX_OPENMP_CHECK_DISABLED([ACTION-IF-DISABLED], [ACTION-IF-ENABLED = FAILURE])
# ---------------------------------------------------------------------
# Check whether OpenMP support is disabled for the current compiler.
# If disabled, run ACTION-IF-DISABLED (defaults to nothing),
# otherwise run ACTION-IF-ENABLED (defaults to failing with an error
# message). The result of the macro is either "yes" or "no". The
# result is cached in the
# acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_disabled (e.g.
# acx_cv_prog_fc_openmp_disabled) variable.
AC_DEFUN([ACX_OPENMP_CHECK_DISABLED], [
AC_CACHE_CHECK([whether OpenMP support is disabled for $[]_AC_CC[]],
  [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_disabled],
  [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#ifndef _OPENMP
      choke me
#endif]])],
    [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_disabled=no],
    [acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_disabled=yes])])
AS_IF([test "x$acx_cv_prog_[]_AC_LANG_ABBREV[]_openmp_disabled" = "xyes"],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([OpenMP support for $[]_AC_CC[] is enabled by default: set []_AC_LANG_PREFIX[]FLAGS accordingly to disable it])])])
])
  
AC_DEFUN([_ACX_LANG_OPENMP_MACRO],
  [AC_LANG_SOURCE([_AC_LANG_DISPATCH([$0], _AC_LANG, $@)])])

m4_define([_ACX_LANG_OPENMP_MACRO(C)], [[
#include <stdio.h>
int main (void) { printf("%i", _OPENMP); return 0; }]])

m4_copy([_ACX_LANG_OPENMP_MACRO(C)], [_ACX_LANG_OPENMP_MACRO(C++)])

m4_define([_ACX_LANG_OPENMP_MACRO(Fortran 77)], [[
      program main
      implicit none
      integer ompver
      ompver = _OPENMP
      write (*, "(i0)") ompver
      end]])

m4_copy([_ACX_LANG_OPENMP_MACRO(Fortran 77)], [_ACX_LANG_OPENMP_MACRO(Fortran)])
