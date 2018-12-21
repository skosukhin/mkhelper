# This file contains M4 macros that help to detect various Fortran compiler
# features.
#
# Usage example:
# AC_FC_PP_SRCEXT([f90])
# AC_FC_FREEFORM
# AC_FC_LINE_LENGTH([unlimited])
#
# AC_LANG([Fortran])
# ACX_FC_VENDOR
# ACX_FC_MACRO_DEFINE
# ACX_FC_INC_SEARCH_FLAG([fc])
# ACX_FC_INC_SEARCH_ORDER([fc], [${acx_cv_fc_inc_search_flag_fc}])
# ACX_FC_INC_SEARCH_FLAG([pp])
# ACX_FC_INC_SEARCH_ORDER([pp], [${acx_cv_fc_inc_search_flag_pp}])
# ACX_FC_INC_SEARCH_FLAG([pp_sys])
# ACX_FC_INC_SEARCH_ORDER([pp_sys], [${acx_cv_fc_inc_search_flag_pp_sys}])
# ACX_FC_MOD_SEARCH_FLAG
# ACX_FC_MOD_OUTPUT_FLAG
# ACX_FC_MOD_OUTPUT_NAME

# ACX_FC_VENDOR([ACTION-IF-SUCCESS = NOTHING],
#               [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Detects the vendor of the Fortran compiler based on its intrinsic
# preprocessor macros. The result is "unknown" or one of the following:
# "intel". "cray", "pgi", "nag", "sun", "gnu".
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_vendor variable.
#
# Originally taken from Autoconf Archive where it is known as
# AX_COMPILER_VENDOR.
#
AC_DEFUN([ACX_FC_VENDOR],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran compiler vendor], [acx_cv_fc_vendor],
     [acx_fc_vendor_options="intel: __INTEL_COMPILER
                              cray: _CRAYFTN
                               pgi: __PGI
                               nag: NAGFOR
                               sun: __SUNPRO_F90,__SUNPRO_F95
                               gnu: __GNUC__,__GFORTRAN__
                           unknown: UNKNOWN"
      for acx_fc_vendor_test in $acx_fc_vendor_options; do
        AS_CASE([$acx_fc_vendor_test],
          [*:], [AS_VAR_SET([acx_fc_vendor_candidate],
                   [$acx_fc_vendor_test])
                 continue],
          [AS_VAR_SET([acx_fc_vendor_defs],
             ["defined("`echo $acx_fc_vendor_test | dnl
sed 's/,/) || defined(/g'`")"])])
        ACX_FC_PROGRAM([[#if !($acx_fc_vendor_defs)
      choke me
#endif]])
        AC_COMPILE_IFELSE([], [break])
      done
      AS_VAR_SET([acx_cv_fc_vendor],
        [`echo $acx_fc_vendor_candidate | cut -d: -f1`])])
   AS_IF([test x"$acx_cv_fc_vendor" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect the compiler vendor])])])])

# ACX_FC_INC_SEARCH_FLAG(HEADER-TYPE,
#                        [ACTION-IF-SUCCESS = NOTHING],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify search paths for the
# HEADER-TYPE (see ACX_FC_INC_LINE for the details).
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_fc_inc_search_flag_<HEADER-TYPE> variable,
# which may contain a significant trailing whitespace.
#
# See _ACX_FC_HDR_FLAGS for the known flags.
#
AC_DEFUN([ACX_FC_INC_SEARCH_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran flag needed to specify search paths for dnl
_ACX_FC_HDR_STR([$1])],
     [acx_cv_fc_inc_search_flag_[$1]],
     [acx_cv_fc_inc_search_flag_[$1]=unknown
      AC_LANG_CONFTEST([[      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine]])
      mkdir conftest.dir && mv conftest.$ac_ext conftest.dir/conftest.inc
      acx_fc_inc_search_flag_[$1]_FCFLAGS_save=$FCFLAGS
      for acx_fc_inc_search_flag_[$1]_candidate in _ACX_FC_HDR_FLAGS([$1]); do
        FCFLAGS="${acx_fc_inc_search_flag_[$1]_FCFLAGS_save} dnl
${acx_fc_inc_search_flag_[$1]_candidate}conftest.dir"
        ACX_FC_PROGRAM([[      call conftest_routine]], [[conftest.inc, [$1]]])
        AC_LINK_IFELSE([],
          [AS_VAR_SET([acx_cv_fc_inc_search_flag_[$1]],
             [$acx_fc_inc_search_flag_[$1]_candidate])
           break])
      done
      FCFLAGS=$acx_fc_inc_search_flag_[$1]_FCFLAGS_save
      rm -rf conftest.dir])
   AS_IF([test x"$acx_cv_fc_inc_search_flag_[$1]" != xunknown],
     [$2],
     [m4_default(
        [$3],
        [AC_MSG_FAILURE([unable to detect the flag needed to specify search dnl
paths for _ACX_FC_HDR_STR([$1])])])])])

# ACX_FC_MOD_SEARCH_FLAG([ACTION-IF-SUCCESS = NOTHING],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify module search paths.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_fc_mod_search_flag variable, which may
# contain a significant trailing whitespace.
#
# Originally taken from the master branch of autoconf where it is known as
# AC_FC_MODULE_FLAG.
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
#
AC_DEFUN([ACX_FC_MOD_SEARCH_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran flag needed to specify module search paths],
     [acx_cv_fc_mod_search_flag],
     [acx_cv_fc_mod_search_flag=unknown
      mkdir conftest.dir
      cd conftest.dir
      AC_COMPILE_IFELSE([[      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
        [cd ..
         acx_fc_mod_search_flag_FCFLAGS_save=$FCFLAGS
         for acx_fc_mod_search_flag in -M -I '-I ' '-M ' -p '-mod ' dnl
'-module ' '-Am -I'; do
dnl Add the flag twice to prevent matching an output flag.
           FCFLAGS="$acx_fc_mod_search_flag_FCFLAGS_save dnl
${acx_fc_mod_search_flag}conftest.dir ${acx_fc_mod_search_flag}conftest.dir"
           ACX_FC_PROGRAM([[      call conftest_routine]],
             [], [conftest_module])
           AC_COMPILE_IFELSE([],
             [acx_cv_fc_mod_search_flag=$acx_fc_mod_search_flag
              break])
         done
         FCFLAGS=$acx_fc_mod_search_flag_FCFLAGS_save])
      rm -rf conftest.dir])
   AS_IF([test x"$acx_cv_fc_mod_search_flag" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect the flag needed specify module dnl
search paths])])])])

# ACX_FC_MOD_OUTPUT_FLAG([ACTION-IF-SUCCESS = NOTHING],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify module output paths.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_fc_mod_output_flag variable, which may
# contain a significant trailing whitespace.
#
# Originally taken from the master branch of autoconf where it is known as
# AC_FC_MODULE_OUTPUT_FLAG.
#
# See ACX_FC_MOD_SEARCH_FLAG for the known flags.
#
AC_DEFUN([ACX_FC_MOD_OUTPUT_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran flag needed to specify module output path],
     [acx_cv_fc_mod_output_flag],
     [AS_MKDIR_P([conftest.dir/sub])
      cd conftest.dir
      acx_cv_fc_mod_output_flag=unknown
      acx_fc_mod_output_flag_FCFLAGS_save=$FCFLAGS
      for acx_fc_mod_output_flag in -J '-J ' -fmod= -moddir= +moddir= dnl
-qmoddir= '-mdir ' '-mod ' '-module ' -M '-Am -M' '-e m -J '; do
        AS_VAR_SET([FCFLAGS],
          ["$acx_fc_mod_output_flag_FCFLAGS_save dnl
${acx_fc_mod_output_flag}sub"])
        AC_COMPILE_IFELSE([[      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
          [cd sub
           ACX_FC_PROGRAM([[      call conftest_routine]],
             [], [conftest_module])
           AC_COMPILE_IFELSE([],
             [acx_cv_fc_mod_output_flag=$acx_fc_mod_output_flag
              cd ..
              break])
           cd ..])
      done
      FCFLAGS=$acx_fc_mod_output_flag_FCFLAGS_save
      cd ..
      rm -rf conftest.dir])
   AS_IF([test x"$acx_cv_fc_mod_output_flag" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect the flag needed to specify module dnl
output path])])])])

# ACX_FC_MACRO_DEFINE([ACTION-IF-SUCCESS = NOTHING],
#                     [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify a preprocessor macro
# definition.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_fc_macro_define variable.
#
# Originally taken from the master branch of autoconf where it is known as
# AC_FC_PP_DEFINE.
#
# Known flags:
# IBM: -WF,-D
# Lahey/Fujitsu: -Wp,-D     older versions???
# f2c: -D or -Wc,-D
# others: -D
#
AC_DEFUN([ACX_FC_MACRO_DEFINE],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran flag needed to define a preprocessor macro],
     [acx_cv_fc_macro_define],
     [acx_cv_fc_macro_define=unknown
      acx_fc_macro_define_FCFLAGS_save=$FCFLAGS
      for acx_fc_macro_define_flag in -D -WF,-D -Wp,-D -Wc,-D ; do
        FCFLAGS="$acx_fc_macro_define_FCFLAGS_save dnl
${acx_fc_macro_define_flag}FOOBAR ${acx_fc_macro_define_flag}ZORK=42"
        ACX_FC_PROGRAM([[#ifndef FOOBAR
      choke me
#endif
#if ZORK != 42
      choke me
#endif]])
        AC_COMPILE_IFELSE([],
          [acx_cv_fc_macro_define=$acx_fc_macro_define_flag
           break])
      done
      FCFLAGS=$acx_fc_macro_define_FCFLAGS_save])
   AS_IF([test x"$acx_cv_fc_macro_define" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect the flag needed to define a dnl
preprocessor macro])])])])

# ACX_FC_INC_SEARCH_ORDER(HEADER-TYPE, INCLUDE-FLAG,
#                         [ACTION-IF-SUCCESS = NOTHING],
#                         [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the search path order for the HEADER-TYPE statement or directive (see
# ACX_FC_INC_LINE for the details). The result is either "unknown" (e.g in the
# case of cross-compilation) or a comma-separated list of identifiers that
# denote directories, in which the compiler searches for an included file:
#   "cwd": current working directory;
#   "flg": directories specified using INCLUDE-FLAG;
#   "src": directory containing the compiled source file;
#   "inc": directory containing the file with the the include statement or
#          directive.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise (i.e.
# the result is "unknown") runs ACTION-IF-FAILURE (defaults to failing with an
# error message).
#
# The result is cached in the acx_cv_fc_inc_search_order_<HEADER-TYPE>
# variable.
#
AC_DEFUN([ACX_FC_INC_SEARCH_ORDER],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for Fortran search path order for _ACX_FC_HDR_STR([$1])],
     [acx_cv_fc_inc_search_order_[$1]],
     [acx_cv_fc_inc_search_order_[$1]=
      AS_IF([test x"$cross_compiling" = xno],
        [AS_MKDIR_P([conftest.dir/src/inc])
         AS_MKDIR_P([conftest.dir/build])
         AS_MKDIR_P([conftest.dir/src/inc2])
         ACX_FC_PROGRAM([ACX_FC_INC_LINE([conftest_inc.inc], [$1])])
dnl Copy the file to the build dir to keep _AC_MSG_LOG_CONFTEST happy.
dnl This copy does not get compiled.
         cp conftest.$ac_ext conftest.dir/build/conftest.$ac_ext
dnl This instance of the file will be compiled.
         mv conftest.$ac_ext conftest.dir/src/conftest.$ac_ext
         AC_LANG_CONFTEST([[      write (*,"(a)") "src"]])
         mv conftest.$ac_ext conftest.dir/src/conftest_write.inc
         AC_LANG_CONFTEST([[      write (*,"(a)") "flg"]])
         mv conftest.$ac_ext conftest.dir/src/inc/conftest_write.inc
         AC_LANG_CONFTEST([[      write (*,"(a)") "inc"]])
         mv conftest.$ac_ext conftest.dir/src/inc2/conftest_write.inc
         AC_LANG_CONFTEST([ACX_FC_INC_LINE([conftest_write.inc], [$1])])
         mv conftest.$ac_ext conftest.dir/src/inc2/conftest_inc.inc
         AC_LANG_CONFTEST([[      write (*,"(a)") "cwd"]])
         mv conftest.$ac_ext conftest.dir/build/conftest_write.inc
         cd conftest.dir/build
         acx_fc_inc_search_order_[$1]_FCFLAGS_save=$FCFLAGS
         FCFLAGS="$FCFLAGS [$2]../src/inc [$2]../src/inc2"
         acx_fc_inc_search_order_[$1]_ac_link_save=$ac_link
         ac_link=`echo "$ac_link" | dnl
sed 's%conftest\(\.\$ac_ext\)%../src/conftest\1%'`
         while :; do
           AC_LINK_IFELSE([],
             [acx_fc_inc_search_order_[$1]_exe_result=`./conftest$ac_exeext`
              AS_IF([test $? -eq 0],
                [AS_CASE([$acx_fc_inc_search_order_[$1]_exe_result],
                   [src], [rm -f ../src/conftest_write.inc],
                   [inc], [rm -f ../src/inc2/conftest_write.inc],
                   [cwd], [rm -f ./conftest_write.inc],
                   [flg], [rm -f ../src/inc/conftest_write.inc dnl
../src/inc2/conftest_write.inc],
                   [break])
                 AS_VAR_APPEND([acx_cv_fc_inc_search_order_[$1]],
                   [" $acx_fc_inc_search_order_[$1]_exe_result"])
                 rm -f ./conftest$ac_exeext],
                [break])],
             [break])
         done
         ac_link=$acx_fc_inc_search_order_[$1]_ac_link_save
         FCFLAGS=$acx_fc_inc_search_order_[$1]_FCFLAGS_save
         cd ../..
         rm -rf conftest.dir])
      AS_IF([test x"$acx_cv_fc_inc_search_order_[$1]" != x],
        [AS_VAR_SET([acx_cv_fc_inc_search_order_[$1]],
           [`echo ${acx_cv_fc_inc_search_order_[$1]} | tr ' ' ','`])],
        [acx_cv_fc_inc_search_order_[$1]=unknown])])
   AS_IF([test x"$acx_cv_fc_inc_search_order_[$1]" != xunknown],
     [$3],
     [m4_default(
        [$4],
        [AC_MSG_FAILURE([unable to detect the search path order for dnl
_ACX_FC_HDR_STR([$1])])])])])

# ACX_FC_MOD_OUTPUT_NAME([ACTION-IF-SUCCESS = NOTHING],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler module file naming template.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_mod_output_name_upper and
# acx_cv_fc_mod_output_name_ext variables. If output module files have
# uppercase names, acx_cv_fc_mod_output_name_upper is "yes", and "no"
# otherwise. The acx_cv_fc_mod_output_name_ext variable stores the file
# extension without the leading dot. Either of the variables can have value
# "unknown". The result is successful if only both of the variables are
# detected.
#
# Originally taken from the master branch of autoconf where it is known as
# AC_FC_MODULE_EXTENSION.
#
AC_DEFUN([ACX_FC_MOD_OUTPUT_NAME],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_MSG_CHECKING([for Fortran module file naming template])
   AS_IF([AS_VAR_TEST_SET([acx_cv_fc_mod_output_name_upper]) &&
          AS_VAR_TEST_SET([acx_cv_fc_mod_output_name_ext])],
     [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
     [mkdir conftest.dir
      cd conftest.dir
      AC_COMPILE_IFELSE([[      module conftest_module
      contains
      subroutine conftest_routine
      write (*,"(a)") "a"
      end subroutine
      end module]],
        [AS_VAR_SET([acx_cv_fc_mod_output_name_ext],
           [`ls | sed -n 's,conftest_module\.,,p'`])
         AS_IF([test x"$acx_cv_fc_mod_output_name_ext" = x],
           [AS_VAR_SET([acx_cv_fc_mod_output_name_ext],
              [`ls | sed -n 's,CONFTEST_MODULE\.,,p'`])
            AS_IF([test x"$acx_cv_fc_mod_output_name_ext" = x],
              [acx_cv_fc_mod_output_name_ext=unknown
               acx_cv_fc_mod_output_name_upper=unknown],
              [acx_cv_fc_mod_output_name_upper=yes])],
           [acx_cv_fc_mod_output_name_upper=no])],
        [acx_cv_fc_mod_output_name_ext=unknown
         acx_cv_fc_mod_output_name_upper=unknown])
      cd ..
      rm -rf conftest.dir])
   AC_MSG_RESULT([uppercase=$acx_cv_fc_mod_output_name_upper dnl
extension=$acx_cv_fc_mod_output_name_ext])
   AS_IF([test x"$acx_cv_fc_mod_output_name_upper" != xunknown &&
          test x"$acx_cv_fc_mod_output_name_ext" != xunknown],
     [$1],
     [m4_default(
        [$2],
        [AC_MSG_FAILURE([unable to detect the module file naming dnl
template])])])])

# ACX_FC_INC_LINE(HEADER-FILE, [HEADER-TYPE = fc])
# -----------------------------------------------------------------------------
# Expands into a line with the include statement or directive for the
# HEADER-FILE. The HEADER-TYPE defines, which actual statement or directive is
# used. HEADER-TYPE can have one the following values:
#   "fc"     for the Fortran "INCLUDE" statement (default);
#   "pp"     for the quoted form of the preprocessor "#include" directive;
#   "pp_sys" for the angle-bracket form of the preprocessor "#include"
#            directive.
#
AC_DEFUN([ACX_FC_INC_LINE],
  [m4_case(m4_default([$2], [fc]),
     [fc], [m4_n([[      include "$1"]])],
     [pp], [m4_n([[@%:@include "$1"]])],
     [pp_sys], [m4_n([[@%:@include <$1>]])],
     [m4_fatal([Unexpected header type '$2'])])])

# ACX_FC_USE_LINE(MODULE, [MODULE-NATURE = default])
# -----------------------------------------------------------------------------
# Expands into a line with the Fortran "use" statement. The MODULE-NATURE
# defines the the nature of the module. MODULE-NATURE can have one of the
# following values:
#   "default"       for ommitting the specification of the module nature;
#   "intrinsic"    for using the module as an intrinsic one;
#   "non_intrinsic" for using the module as a non-intrinsic one.
#
AC_DEFUN([ACX_FC_USE_LINE],
  [m4_case(m4_default([$2], [default]),
     [default], [m4_n([[      use $1]])],
     [intrinsic], [m4_n([[      use, intrinsic $1]])],
     [non_intrinsic], [m4_n([[      use, non_intrinsic $1]])],
     [m4_fatal([Unexpected module nature '$2'])])])

# ACX_FC_PROGRAM([BODY], [HEADER-FILES], [MODULES])
# -----------------------------------------------------------------------------
# Expands into a source file, which includes each files on the M4 list
# HEADER-FILES and defines a program consisting of the BODY prepended by the
# use statements for each module on the M4 list MODULES.
#
# HEADER-FILES is an M4 list of M4 lists. Each element of the HEADER-FILES is
# interpreted as a pair of the HEADER-FILE and HEADER-TYPE (see ACX_FC_INC_LINE
# for the details).
#
# MODULES is an M4 list of M4 lists. Each element of the MODULES is interpreted
# as a pair of the MODULE and MODULE-NATURE (see ACX_FC_USE_LINE for the
# details).
#
AC_DEFUN([ACX_FC_PROGRAM],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_LANG_CONFTEST([dnl
m4_map([ACX_FC_INC_LINE], [$2])dnl
m4_n([[      program main]])dnl
m4_map([ACX_FC_USE_LINE], [$3])dnl
m4_ifnblank([$1],[m4_n([$1])])dnl
[      end]])])

# _ACX_FC_HDR_STR([HEADER-TYPE = fc])
# -----------------------------------------------------------------------------
# Expands into a shell string with the description of the
# HEADER-TYPE (see ACX_FC_INC_LINE for the details).
#
AC_DEFUN([_ACX_FC_HDR_STR],
  [m4_case(m4_default([$1], [fc]),
     [fc], [[the \"INCLUDE\" statement]],
     [pp], [[the quoted form of the \"#include\" directive]],
     [pp_sys], [[the angle-bracket form of the \"#include\" directive]],
     [m4_fatal([Unexpected header type '$1'])])])

# _ACX_FC_HDR_FLAGS([HEADER-TYPE = fc])
# -----------------------------------------------------------------------------
# Expands into a blank-separated list of known Fortran compiler flags that can
# be used to specify search paths for the HEADER-TYPE (see ACX_FC_INC_LINE for
# the details).
#
AC_DEFUN([_ACX_FC_HDR_FLAGS],
  [m4_bmatch(m4_default([$1], [fc]),
     [fc], [[-I '-I ']],
     [[pp|pp_sys]], [[-I '-I ' '-WF,-I' '-Wp,-I']],
     [m4_fatal([Unexpected header type '$1'])])])