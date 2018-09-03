# ACX_FC_MODULE_INC_FLAG([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_MODULE_FLAG.
# ---------------------------------------------------------------------
# Find a flag to include Fortran 90 modules from another directory.
# If successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise
# run ACTION-IF-FAILURE (defaults to failing with an error message).
# The module flag is cached in the acx_cv_fc_module_flag variable.
# It may contain significant trailing whitespace.
#
# Known flags:
# gfortran: -Idir, -I dir (-M dir, -Mdir (deprecated),
#                          -Jdir for writing)
# g95: -I dir (-fmod=dir for writing)
# SUN: -Mdir, -M dir (-moddir=dir for writing;
#                     -Idir for includes is also searched)
# HP: -Idir, -I dir (+moddir=dir for writing)
# IBM: -Idir (-qmoddir=dir for writing)
# Intel: -Idir -I dir (-mod dir for writing)
# Absoft: -pdir
# Lahey: -mod dir
# Cray: -module dir, -p dir (-J dir for writing)
#       -e m is needed to enable writing .mod files at all
# Compaq: -Idir
# NAGWare: -I dir
# PathScale: -I dir  (but -module dir is looked at first)
# Portland: -module dir (first -module also names dir for writing)
# Fujitsu: -Am -Idir (-Mdir for writing is searched first, then '.',
#                     then -I)
#                    (-Am indicates how module information is saved)
AC_DEFUN([ACX_FC_MODULE_INC_FLAG],[
AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([for Fortran flag to include modules from a specified directory], [acx_cv_fc_module_inc_flag], [
AC_LANG_PUSH([Fortran])
acx_cv_fc_module_inc_flag=unknown
mkdir conftest.dir
cd conftest.dir
AC_COMPILE_IFELSE([[
      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
  [cd ..
  acx_fc_module_inc_flag_FCFLAGS_save=$FCFLAGS
  # Flag ordering is significant for gfortran and Sun.
  for acx_fc_module_inc_flag in -M -I '-I ' '-M ' -p '-mod ' '-module ' '-Am -I'; do
    # Add the flag twice to prevent matching an output flag.
    FCFLAGS="$acx_fc_module_inc_flag_FCFLAGS_save \
      ${acx_fc_module_inc_flag}conftest.dir ${acx_fc_module_inc_flag}conftest.dir"
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
      use conftest_module
      call conftest_routine]])],
      [acx_cv_fc_module_inc_flag=$acx_fc_module_inc_flag
      break])
  done
  FCFLAGS=$acx_fc_module_inc_flag_FCFLAGS_save])
rm -rf conftest.dir
AC_LANG_POP([Fortran])
])
AS_IF([test x"$acx_cv_fc_module_inc_flag" != xunknown],
  [FC_MODINC=$acx_cv_fc_module_inc_flag
  $1],
  [FC_MODINC=
  m4_default([$2], [AC_MSG_ERROR([unable to detect flag needed to include modules from a specified directory])])])
AC_SUBST([FC_MODINC])
])
