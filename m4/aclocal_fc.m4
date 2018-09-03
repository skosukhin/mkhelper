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
  for acx_fc_module_inc_flag in -M '-I ' '-I ' '-M ' -p '-mod ' '-module ' '-Am -I'; do
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
# For known flags, see the documentation of ACX_FC_MODULE_INC_FLAG
# above.
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
AS_IF([test "$cross_compiling" = yes], [], [
AC_LANG_PUSH([Fortran])
AS_MKDIR_P([conftest.dir/src/inc])
AC_LANG_CONFTEST([AC_LANG_PROGRAM([], [[$1 "conftest_inc.inc"]])])
mv conftest.$ac_ext conftest.dir/src/conftest.$ac_ext
AC_LANG_CONFTEST([[
      write (*,"(a)") "src"]])
mv conftest.$ac_ext conftest.dir/src/conftest_write.inc
AC_LANG_CONFTEST([[
      write (*,"(a)") "flg"]])
mv conftest.$ac_ext conftest.dir/src/inc/conftest_write.inc
AS_MKDIR_P([conftest.dir/src/inc2])
AC_LANG_CONFTEST([[
      write (*,"(a)") "inc"]])
mv conftest.$ac_ext conftest.dir/src/inc2/conftest_write.inc
AC_LANG_CONFTEST([[$1 "conftest_write.inc"]])
mv conftest.$ac_ext conftest.dir/src/inc2/conftest_inc.inc
AS_MKDIR_P([conftest.dir/build])
AC_LANG_CONFTEST([[
      write (*,"(a)") "cwd"]])
mv conftest.$ac_ext conftest.dir/build/conftest_write.inc
cd conftest.dir/build
_acx_fc_inc_order_FCFLAGS_save=$FCFLAGS
FCFLAGS="$FCFLAGS -I../src/inc -I../src/inc2"
_acx_fc_inc_order_ac_link_save=$ac_link
ac_link=`echo "$ac_link" | sed 's%conftest\(\.\$ac_ext\)%../src/conftest\1%'`
m4_pushdef([_AC_MSG_LOG_CONFTEST],
[AS_ECHO(["$as_me: failed program was:"]) >&AS_MESSAGE_LOG_FD
sed 's/^/| /' ../src/conftest.$ac_ext >&AS_MESSAGE_LOG_FD
])
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
m4_popdef([_AC_MSG_LOG_CONFTEST])
ac_link=$_acx_fc_inc_order_ac_link_save
FCFLAGS=$_acx_fc_inc_order_FCFLAGS_save
cd ..
cd ..
rm -rf conftest.dir
])
AS_IF([test x"$_acx_fc_inc_order" != x],
  [_acx_fc_inc_order=`echo $_acx_fc_inc_order | tr ' ' ','`],
  [_acx_fc_inc_order=unknown])
])

# ACX_FC_MODULE_FILE_NAMING([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_MODULE_EXTENSION.
# ---------------------------------------------------------------------
# Find the Fortran module file naming template. If successful, run
# ACTION-IF-SUCCESS (defaults to nothing), otherwise run
# ACTION-IF-FAILURE (defaults to failing with an error message).
# The result is cached in the acx_cv_fc_module_file_naming variable,
# which equeals either to UPPERCASE[extension], denoting that the
# module files are named in uppercase, or to lowercase[extension],
# denoting that the module files are named in lowercase.
AC_DEFUN([ACX_FC_MODULE_FILE_NAMING],
[AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([for Fortran module file naming template], [acx_cv_fc_module_file_naming],
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
  [acx_cv_fc_module_file_naming=`ls | sed -n 's,^conftest_module,lowercase,p'`
  AS_IF([test x"$acx_cv_fc_module_file_naming" = x],
    [acx_cv_fc_module_file_naming=`ls | sed -n 's,^CONFTEST_MODULE,UPPERCASE,p'`
    AS_IF([test x"$acx_cv_fc_module_file_naming" = x],
      [acx_cv_fc_module_file_naming=unknown])])])
cd ..
rm -rf conftest.dir
AC_LANG_POP(Fortran)])
AS_IF([test x"$acx_cv_fc_module_file_naming" != xunknown],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([unable to detect Fortran module file naming template])])])
])

# ACX_FC_PP_DEFINE([ACTION-IF-SUCCESS], [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Originally taken from the master branch of autoconf where it is known
# as AC_FC_PP_DEFINE.
# -------------------------------------------------------------------
# Find a flag to specify defines for preprocessed Fortran.  Not all
# Fortran compilers use -D. Substitute FC_DEFINE with the result and
# call ACTION-IF-SUCCESS (defaults to nothing) if successful, and
# ACTION-IF-FAILURE (defaults to failing with an error message) if not.
#
# Known flags:
# IBM: -WF,-D
# Lahey/Fujitsu: -Wp,-D     older versions???
# f2c: -D or -Wc,-D
# others: -D
AC_DEFUN([ACX_FC_PP_DEFINE],
[AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([how to define symbols for preprocessed Fortran], [acx_cv_fc_pp_define],
AC_LANG_PUSH([Fortran])
[acx_cv_fc_pp_define=unknown
acx_fc_pp_define_FCFLAGS_save=$FCFLAGS
for acx_fc_pp_define_flag in -D -WF,-D -Wp,-D -Wc,-D ; do
  FCFLAGS="$acx_fc_pp_define_FCFLAGS_save ${acx_fc_pp_define_flag}FOOBAR ${acx_fc_pp_define_flag}ZORK=42"
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#ifndef FOOBAR
      choke me
#endif
#if ZORK != 42
      choke me
#endif]])],
  [acx_cv_fc_pp_define=$acx_fc_pp_define_flag
  break])
done
FCFLAGS=$acx_fc_pp_define_FCFLAGS_save
AC_LANG_POP([Fortran])
])
AS_IF([test x"$xac_cv_fc_pp_define" != xunknown],
  [FC_DEFINE=$acx_cv_fc_pp_define
  $1],
  [FC_DEFINE=
  m4_default([$2], [AC_MSG_ERROR([Fortran does not allow to define preprocessor symbols])])])
AC_SUBST([FC_DEFINE])
])

# ACX_PROG_FC_MPI_CHECK([ACTION-IF-TRUE], [ACTION-IF-FALSE = FAILURE])
# ----------------------------------------------------------------------------
# Checks if Fortran compiler support MPI.
AC_DEFUN([ACX_PROG_FC_MPI_CHECK],[
AC_CACHE_CHECK([whether Fortran 90 can link a simple MPI program], [acx_cv_prog_fc_mpi],
[AC_LANG_PUSH([Fortran])
AC_LINK_IFELSE([AC_LANG_CALL([],[MPI_INIT])],
  [ acx_cv_prog_fc_mpi=yes ],
  [ acx_cv_prog_fc_mpi=no ])
AC_LANG_POP([Fortran])
])
AS_IF([test x"$acx_cv_prog_fc_mpi" = xyes],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([Fortran 90 cannot link a simple MPI program])])])
])

