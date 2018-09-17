# ACX_FC_MODULE_FILE_NAMING([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_MODULE_EXTENSION.
# ---------------------------------------------------------------------
# Find the Fortran module file naming template. If successful, run
# ACTION-IF-SUCCESS (defaults to nothing), otherwise run
# ACTION-IF-FAILURE (defaults to failing with an error message).
# The result is cached in the acx_cv_fc_module_file_naming_upper and
# acx_cv_fc_module_file_naming_ext variables. If module files are named
# in uppercase, acx_cv_fc_module_file_naming_upper is "yes", and "no"
# otherwise. The acx_cv_fc_module_file_naming_ext variable stores the
# file extension without leading dot. Either of the variables can have
# value "unknown" if the detection failed. ACTION-IF-SUCCESS is run only
# when both of the variables are detected successfuly.
AC_DEFUN([ACX_FC_MODULE_FILE_NAMING],
[AC_REQUIRE([AC_PROG_FC])
AC_MSG_CHECKING([for Fortran module file naming template])
AS_IF([AS_VAR_TEST_SET([acx_cv_fc_module_file_naming_upper]) &&
  AS_VAR_TEST_SET([acx_cv_fc_module_file_naming_ext])], [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
[AC_LANG_PUSH(Fortran)
mkdir conftest.dir
cd conftest.dir
AC_COMPILE_IFELSE([[
      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
  [acx_cv_fc_module_file_naming_ext=`ls | sed -n 's,conftest_module\.,,p'`
  AS_IF([test x"$acx_cv_fc_module_file_naming_ext" = x],
    [acx_cv_fc_module_file_naming_ext=`ls | sed -n 's,CONFTEST_MODULE\.,,p'`
    AS_IF([test x"$acx_cv_fc_module_file_naming_ext" = x],
      [acx_cv_fc_module_file_naming_ext=unknown
      acx_cv_fc_module_file_naming_upper=unknown],
      [acx_cv_fc_module_file_naming_upper=yes])],
    [acx_cv_fc_module_file_naming_upper=no])])
cd ..
rm -rf conftest.dir
AC_LANG_POP(Fortran)])
AC_MSG_RESULT([uppercase=$acx_cv_fc_module_file_naming_upper extension=$acx_cv_fc_module_file_naming_ext])
AS_IF([test x"$acx_cv_fc_module_file_naming_upper" != xunknown &&
  test x"$acx_cv_fc_module_file_naming_ext" != xunknown],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([unable to detect Fortran module file naming template])])])
])
