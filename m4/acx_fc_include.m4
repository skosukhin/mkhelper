# ACX_FC_INCLUDE_FLAG([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Find a flag to specify search paths for Fortran "include" statement.
# If successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise
# run ACTION-IF-FAILURE (defaults to failing with an error message).
# The flag is cached in the acx_cv_fc_include_flag variable.
# It may contain significant trailing whitespace.
AC_DEFUN([ACX_FC_INCLUDE_FLAG],
  [AC_CACHE_CHECK([for Fortran flag to specify search paths for the "include" statement], [acx_cv_fc_include_flag],
     [_ACX_FC_INCLUDE_FLAG([      include], [-I '-I '])
      acx_cv_fc_include_flag=$_acx_fc_include_flag])
   AS_IF([test x"$acx_cv_fc_include_flag" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect Fortran flag needed to specify search paths for the "include" statement])])])])

# ACX_FC_INCLUDE_ORDER([INCLUDE-FLAG], [ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with "include" statement.
# If successful, run ACTION-IF-SUCCESS (defaults to nothing), otherwise
# run ACTION-IF-FAILURE (defaults to failing with an error message).
# The result is cached in the acx_cv_fc_include_order variable.
#
# For the description of result, see the documentation of _ACX_FC_INCLUDE_ORDER.
AC_DEFUN([ACX_FC_INCLUDE_ORDER],
  [AC_CACHE_CHECK([for Fortran's include order of the "include" statement], [acx_cv_fc_include_order],
     [_ACX_FC_INCLUDE_ORDER([      include], [$1])
      acx_cv_fc_include_order=$_acx_fc_include_order])
   AS_IF([test x"$acx_cv_fc_include_order" != xunknown],
     [$2],
     [m4_default(
        [$3],
        [AC_MSG_FAILURE([unable to detect Fortran's include order of the "include" statement])])])])

# _ACX_FC_INCLUDE_FLAG([INCLUDE-STATEMENT-OR-DIRECTIVE], [FLAGS-TO-CHECK])
# ---------------------------------------------------------------------
# Check for each flag in the blank-separated list FLAGS-TO-CHECK and
# return the first one that can be used to specify search paths for
# INCLUDE-STATEMENT-OR-DIRECTIVE ('INCLUDE' or '#include').
# If none of the FLAGS-TO-CHECK can be used, the result is "unknown".
# The result is stored in the _acx_fc_include_flag variable.
AC_DEFUN([_ACX_FC_INCLUDE_FLAG],
  [AC_REQUIRE([AC_PROG_FC])
   AC_LANG_PUSH([Fortran])
   _acx_fc_include_flag=unknown
   mkdir conftest.dir
   AC_LANG_CONFTEST([[
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine]])
   mv conftest.$ac_ext conftest.dir/conftest.inc
   _acx_fc_include_flag_FCFLAGS_save=$FCFLAGS
   for _acx_fc_include_flag_candidate in $2; do
     FCFLAGS="$_acx_fc_include_flag_FCFLAGS_save ${_acx_fc_include_flag_candidate}conftest.dir"
     AC_LINK_IFELSE([AC_LANG_SOURCE([[
$1 "conftest.inc"
      program main
      call conftest_routine
      end]])],
       [_acx_fc_include_flag=$_acx_fc_include_flag_candidate
        break])
   done
   FCFLAGS=$_acx_fc_include_flag_FCFLAGS_save
   rm -rf conftest.dir
   AC_LANG_POP([Fortran])])

# _ACX_FC_INCLUDE_ORDER([INCLUDE-STATEMENT-OR-DIRECTIVE], [INCLUDE-FLAG])
# ----------------------------------------------------------------------------
# Find the file inclusion order performed with INCLUDE-STATEMENT-OR_DIRECTIVE
# ('INCLUDE' or '#include'). The result is either "unknown" (e.g in the case
# of cross-compilation) or a comma-separated list of identifiers that denote
# directories, in which the compiler searches for an included file:
#
#   cwd: current working directory;
#   flg: directories specified using INCLUDE-FLAG flag;
#   src: directory containing the compiled source file;
#   inc: directory containing the file with the INCLUDE-STATEMENT-OR-DIRECTIVE.
#
# The result is stored to the variable _acx_fc_include_order.
AC_DEFUN([_ACX_FC_INCLUDE_ORDER],
  [AC_REQUIRE([AC_PROG_FC])
   _acx_fc_include_order=
   AS_IF([test x"$cross_compiling" = xno],
     [AC_LANG_PUSH([Fortran])
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
      _acx_fc_include_order_FCFLAGS_save=$FCFLAGS
      FCFLAGS="$FCFLAGS [$2]../src/inc [$2]../src/inc2"
      _acx_fc_include_order_ac_link_save=$ac_link
      ac_link=`echo "$ac_link" | sed 's%conftest\(\.\$ac_ext\)%../src/conftest\1%'`
      while :; do
        AC_LINK_IFELSE([],
          [_acx_fc_include_order_exe_result=`./conftest$ac_exeext`
           AS_IF([test $? -eq 0],
             [AS_CASE([$_acx_fc_include_order_exe_result],
                [src], [rm -f ../src/conftest_write.inc],
                [inc], [rm -f ../src/inc2/conftest_write.inc],
                [cwd], [rm -f ./conftest_write.inc],
                [flg], [rm -f ../src/inc/conftest_write.inc ../src/inc2/conftest_write.inc],
                [break])
              _acx_fc_include_order="$_acx_fc_include_order $_acx_fc_include_order_exe_result"
              rm -f ./conftest$ac_exeext],
             [break])],
          [break])
      done
      ac_link=$_acx_fc_include_order_ac_link_save
      FCFLAGS=$_acx_fc_include_order_FCFLAGS_save
      cd ../..
      rm -rf conftest.dir
      AC_LANG_POP([Fortran])])
   AS_IF([test x"$_acx_fc_include_order" != x],
     [_acx_fc_include_order=`echo $_acx_fc_include_order | tr ' ' ','`],
     [_acx_fc_include_order=unknown])])
