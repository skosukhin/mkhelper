# ACX_FC_INCLUDE_ORDER([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with "include" statement. If
# successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise run
# ACTION-IF-FAILURE (defaults to failing with an error message). The result is
# cached in the acx_cv_fc_hash_include_order variable.
#
# For the description of result, see the documentation of _ACX_FC_INC_ORDER.
AC_DEFUN([ACX_FC_INCLUDE_ORDER],[
AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([for Fortran's include order of the "include" statement], [acx_cv_fc_include_order],
[_ACX_FC_INC_ORDER([      include])
acx_cv_fc_include_order=$_acx_fc_inc_order
])
AS_IF([test x"$acx_cv_fc_include_order" != xunknown],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([unable to detect Fortran's include order of the "include" statement])])])
])

# ACX_FC_HASH_INCLUDE_ORDER([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with "#include" statement. If
# successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise run
# ACTION-IF-FAILURE (defaults to failing with an error message). The result is
# cached in the acx_cv_fc_hash_include_order variable.
#
# For the description of result, see the documentation of _ACX_FC_INC_ORDER.
AC_DEFUN([ACX_FC_HASH_INCLUDE_ORDER],[
AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([[for Fortran's include order of the "#include" statement]], [acx_cv_fc_hash_include_order],
[_ACX_FC_INC_ORDER([#include])
acx_cv_fc_hash_include_order=$_acx_fc_inc_order
])
AS_IF([test x"$acx_cv_fc_hash_include_order" != xunknown],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([[unable to detect Fortran's include order of the "#include" statement]])])])
])

# _ACX_FC_INC_ORDER([INCLUDE-STATEMENT])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with INCLUDE-STATEMENT. The result
# is either "unknown" (e.g in the case of cross-compilation) or a
# comma-separated list of identifiers that denote directories, in which the
# compiler searches for an included file:
#
#   cwd: current working directory;
#   flg: directories specified using -I flag;
#   src: directory containing the compiled source file;
#   inc: directory containing the file with the INCLUDE-STATEMENT.
#
# The result is stored to the variable _acx_fc_inc_order.
AC_DEFUN([_ACX_FC_INC_ORDER],[
_acx_fc_inc_order=
AS_IF([test x"$cross_compiling" = xno], [
AC_LANG_PUSH([Fortran])
AS_MKDIR_P([conftest.dir/src/inc])
AS_MKDIR_P([conftest.dir/build])
AS_MKDIR_P([conftest.dir/src/inc2])
AC_LANG_CONFTEST([AC_LANG_PROGRAM([], [[$1 "conftest_inc.inc"]])])
dnl Copy the file to the build dir to keep _AC_MSG_LOG_CONFTEST happy.
dnl This copy does not get compiled.
cp conftest.$ac_ext conftest.dir/build/conftest.$ac_ext
dnl This instance of the file will be compiled.
mv conftest.$ac_ext conftest.dir/src/conftest.$ac_ext
AC_LANG_CONFTEST([[
      write (*,"(a)") "src"]])
mv conftest.$ac_ext conftest.dir/src/conftest_write.inc
AC_LANG_CONFTEST([[
      write (*,"(a)") "flg"]])
mv conftest.$ac_ext conftest.dir/src/inc/conftest_write.inc
AC_LANG_CONFTEST([[
      write (*,"(a)") "inc"]])
mv conftest.$ac_ext conftest.dir/src/inc2/conftest_write.inc
AC_LANG_CONFTEST([[$1 "conftest_write.inc"]])
mv conftest.$ac_ext conftest.dir/src/inc2/conftest_inc.inc
AC_LANG_CONFTEST([[
      write (*,"(a)") "cwd"]])
mv conftest.$ac_ext conftest.dir/build/conftest_write.inc
cd conftest.dir/build
_acx_fc_inc_order_FCFLAGS_save=$FCFLAGS
FCFLAGS="$FCFLAGS -I../src/inc -I../src/inc2"
_acx_fc_inc_order_ac_link_save=$ac_link
ac_link=`echo "$ac_link" | sed 's%conftest\(\.\$ac_ext\)%../src/conftest\1%'`
while :; do
  AC_LINK_IFELSE(,[
    _acx_fc_inc_order_exe_result=`./conftest$ac_exeext`
    AS_IF([test $? -eq 0], [
      AS_CASE([$_acx_fc_inc_order_exe_result],
        [src], [rm -f ../src/conftest_write.inc],
        [inc], [rm -f ../src/inc2/conftest_write.inc],
        [cwd], [rm -f ./conftest_write.inc],
        [flg], [rm -f ../src/inc/conftest_write.inc ../src/inc2/conftest_write.inc],
        [break])
      _acx_fc_inc_order="$_acx_fc_inc_order $_acx_fc_inc_order_exe_result"
      rm -f ./conftest$ac_exeext],
      [break])],
    [break])
done
ac_link=$_acx_fc_inc_order_ac_link_save
FCFLAGS=$_acx_fc_inc_order_FCFLAGS_save
cd ..
cd ..
rm -rf conftest.dir
AC_LANG_POP([Fortran])
])
AS_IF([test x"$_acx_fc_inc_order" != x],
  [_acx_fc_inc_order=`echo $_acx_fc_inc_order | tr ' ' ','`],
  [_acx_fc_inc_order=unknown])
])
