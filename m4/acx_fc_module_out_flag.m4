# ACX_FC_MODULE_OUT_FLAG([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_MODULE_OUTPUT_FLAG.
# ---------------------------------------------------------------------
# Find a flag to write Fortran 90 module information to another
# directory. If successful, run ACTION-IF-SUCCESS (defaults to
# nothing), otherwise run ACTION-IF-FAILURE (defaults to failing with
# an error message). The module flag is cached in the
# acx_cv_fc_module_output_flag variable. It may contain significant
# trailing whitespace.
#
# For known flags, see the documentation of ACX_FC_MODULE_INC_FLAG.
AC_DEFUN([ACX_FC_MODULE_OUT_FLAG],[
AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([for Fortran flag to store modules to a specified directory], [acx_cv_fc_module_out_flag],
[AC_LANG_PUSH([Fortran])
AS_MKDIR_P([conftest.dir/sub])
cd conftest.dir
acx_cv_fc_module_out_flag=unknown
acx_fc_module_out_flag_FCFLAGS_save=$FCFLAGS
# Flag ordering is significant: put flags late which some compilers use
# for the search path.
for acx_fc_module_out_flag in -J '-J ' -fmod= -moddir= +moddir= -qmoddir= '-mdir ' '-mod ' \
	      '-module ' -M '-Am -M' '-e m -J '; do
  FCFLAGS="$acx_fc_module_out_flag_FCFLAGS_save ${acx_fc_module_out_flag}sub"
  AC_COMPILE_IFELSE([[
      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
    [cd sub
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
      use conftest_module
      call conftest_routine]])],
      [acx_cv_fc_module_out_flag=$acx_fc_module_out_flag
      cd ..
      break])
    cd ..])
done
FCFLAGS=$acx_fc_module_out_flag_FCFLAGS_save
cd ..
rm -rf conftest.dir
AC_LANG_POP([Fortran])
])
AS_IF([test x"$acx_cv_fc_module_out_flag" != xunknown],
  [FC_MODOUT=$acx_cv_fc_module_out_flag
  $1],
  [FC_MODOUT=
  m4_default([$2], [AC_MSG_ERROR([unable to detect flag needed to stor modules to a specified directory])])])
AC_SUBST([FC_MODOUT])
])
