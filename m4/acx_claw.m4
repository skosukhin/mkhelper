# ACX_PROG_CLAW([LIST-OF-PREPROCESSORS = clawfc])
# -----------------------------------------------------------------------------
# See https://github.com/claw-project/claw-compiler
# -----------------------------------------------------------------------------
# Searches for the CLAW preprocessor command among the values of the
# blank-separated list LIST-OF-PREPROCESSORS (defaults to a single value
# "clawfc"). Declares precious variables CLAW and CLAWFLAGS to be set to the
# preprocessor command and the preprocessor flags, respectively. If the
# environment variable CLAW is set, values of the list LIST-OF-PREPROCESSORS
# are ignored.
#
# Checks whether the preprocessor can actually produce Fortran source code. The
# result is either "yes" or "no" and is cached in the acx_cv_prog_claw_works
# variable.
#
AC_DEFUN([ACX_PROG_CLAW],
  [AC_REQUIRE([AC_PROG_FC])dnl
   AC_ARG_VAR([CLAW], [CLAW preprocessor command])dnl
   AC_ARG_VAR([CLAWFLAGS], [CLAW preprocessor flags])dnl
   AS_IF([test -z "$CLAW"],
     [AC_CHECK_PROGS([CLAW], [m4_default([$1], [clawfc])])])
   _AS_ECHO_LOG([checking for CLAW preprocessor version])
   set dummy $CLAW
   acx_tmp=$[2]
   _AC_DO_LIMIT([$acx_tmp --version >&AS_MESSAGE_LOG_FD])
   AC_CACHE_VAL([acx_cv_prog_clawfc_works],
     [acx_cv_prog_clawfc_works=no
      AS_MKDIR_P([conftest.dir])
      cd conftest.dir
      AC_MSG_CHECKING([whether the CLAW preprocessor works])
      AC_LANG_PUSH([Fortran])
      AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      module conftest_module
      end module]])])
      AC_TRY_COMMAND(
        [$CLAW -f -o conftest.claw.$ac_ext $CLAWFLAGS conftest.$ac_ext dnl
>&AS_MESSAGE_LOG_FD])
      AS_IF([test $ac_status -eq 0 && test -f conftest.claw.$ac_ext],
        [AC_MSG_RESULT([yes])
         AC_MSG_CHECKING([whether $FC can compile code produced by $CLAW])
         mv conftest.claw.$ac_ext conftest.$ac_ext
         AC_COMPILE_IFELSE([],
           [AC_MSG_RESULT([yes])
            acx_cv_prog_clawfc_works=yes],
           [AC_MSG_RESULT([no])])],
        [AC_MSG_RESULT([no])])
      AC_LANG_PUSH([Fortran])
      cd ..
      rm -rf conftest.dir])])

# ACX_CLAW_MODULE_OUT_FLAG([ACTION-IF-SUCCESS],
#                          [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the CLAW preprocessor flag needed to specify module output path.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_claw_module_out_flag variable, which may
# contain a significant trailing whitespace.
#
# Known flags:
# CLAW 2.0.x: -Jdir
# CLAW 2.1.x: -MO dir
#
AC_DEFUN([ACX_CLAW_MODULE_OUT_FLAG],
  [AC_REQUIRE([ACX_PROG_CLAW])dnl
   AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for CLAW preprocessor flag needed to specify output path dnl
for module files], [acx_cv_claw_module_out_flag],
     [acx_cv_claw_module_out_flag=unknown
      AS_MKDIR_P([conftest.dir/sub])
      cd conftest.dir
      AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      contains
      subroutine conftest_routine
      end subroutine
      end module]])])
      for acx_flag in '-MO ' -J; do
        AC_TRY_COMMAND(
        [$CLAW -f -o conftest.claw.$ac_ext ${acx_flag}sub $CLAWFLAGS dnl
conftest.$ac_ext >&AS_MESSAGE_LOG_FD])
        AC_TRY_COMMAND([test -f sub/conftest_module.xmod])
        AS_IF([test $ac_status -eq 0],
          [acx_cv_claw_module_out_flag=$acx_flag
           break])
      done
      cd ..
      rm -rf conftest.dir])
   AS_VAR_IF([acx_cv_claw_module_out_flag], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect CLAW preprocessor flag needed to dnl
specify output path for module files])])], [$1])])

# ACX_CLAW_MODULE_IN_FLAG([ACTION-IF-SUCCESS],
#                         [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the CLAW preprocessor flag needed to specify module search paths.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the acx_cv_claw_module_in_flag variable, which may
# contain a significant trailing whitespace.
#
# Known flags:
# CLAW 2.0.x: -Idir
# CLAW 2.1.x: -Mdir
#
AC_DEFUN([ACX_CLAW_MODULE_IN_FLAG],
  [dnl
dnl CLAW 2.1.x does not generate module files unless provided a directory where
dnl to store them:
   AC_REQUIRE([ACX_CLAW_MODULE_OUT_FLAG])dnl
   AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([for CLAW preprocessor flag needed to specify search paths dnl
for module files], [acx_cv_claw_module_in_flag],
     [acx_cv_claw_module_in_flag=unknown
      AS_MKDIR_P([conftest.dir/sub])
      cd conftest.dir
      AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      contains
      subroutine conftest_routine
      end subroutine
      end module]])])
      AC_TRY_COMMAND(
        [$CLAW -f -o conftest.claw.$ac_ext ${acx_cv_claw_module_out_flag}sub dnl
$CLAWFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD])
      AS_IF([test $ac_status -eq 0],
        [rm -f conftest.claw.$ac_ext
         AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      program main
      use conftest_module, only : conftest_routine
      implicit none
      call conftest_routine()
      end]])])
         for acx_flag in -M -I; do
           AC_TRY_COMMAND([$CLAW -f --no-dep -o conftest.claw.$ac_ext dnl
dnl Add the flag twice to make sure that we can specify it multiple times.
${acx_flag}sub ${acx_flag}sub $CLAWFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD])
           AS_IF([test $ac_status -eq 0 && dnl
test -n "`cat conftest.claw.$ac_ext`"],
             [acx_cv_claw_module_in_flag=$acx_flag
              break])
         done])
      cd ..
      rm -rf conftest.dir])
   AS_VAR_IF([acx_cv_claw_module_in_flag], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect CLAW preprocessor flag needed to dnl
specify search paths for module files])])], [$1])])

# ACX_CLAW_MODULE_GEN([ACTION-IF-SUCCESS],
#                     [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the CLAW preprocessor supports explicit Fortran module file
# extraction while ignoring unsupported Fortran constructs in the non-interface
# parts of the code. The result is either "yes" or "no".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_claw_supports_module_gen variable.
#
AC_DEFUN([ACX_CLAW_MODULE_GEN],
  [AC_REQUIRE([ACX_PROG_CLAW])dnl
   AC_REQUIRE([ACX_CLAW_MODULE_OUT_FLAG])dnl
   AC_LANG_ASSERT([Fortran])dnl
   AC_CACHE_CHECK([whether the CLAW preprocessor supports the explicit dnl
module file extraction], [acx_cv_claw_supports_module_gen],
     [acx_cv_claw_supports_module_gen=no
      AS_MKDIR_P([conftest.dir/sub])
      cd conftest.dir
      AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      contains
      subroutine conftest_routine
      character(len=:), pointer :: ptr
      character(len=1), target :: dummy
      dummy = ' '
      ptr => dummy(1:0)
      end subroutine
      end module]])])
      AC_TRY_COMMAND(
        [$CLAW -f -o conftest.claw.$ac_ext --gen-mod-files dnl
${acx_cv_claw_module_out_flag}sub $CLAWFLAGS conftest.$ac_ext dnl
>&AS_MESSAGE_LOG_FD])
      AC_TRY_COMMAND([test -f sub/conftest_module.xmod])
      AS_IF([test $ac_status -eq 0], [acx_cv_claw_supports_module_gen=yes])
      cd ..
      rm -rf conftest.dir])
   AS_VAR_IF([acx_cv_claw_supports_module_gen], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([CLAW preprocessor does not support the explicit dnl
module file extractions])])])])

# ACX_CLAW_ACCEPTS([CLAWFLAGS],
#                  [ACTION-IF-SUCCESS],
#                  [ACTION-IF-FAILURE = FAILURE],
#                  [CACHE-VAR = no caching])
# -----------------------------------------------------------------------------
# Checks whether the CLAW preprocessor accepts CLAWFLAGS. The result is either
# "yes" or "no".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is stored in the acx_claw_accepts variable and optionally cached
# in the CACHE-VAR variable (no caching by default).
#
AC_DEFUN([ACX_CLAW_ACCEPTS],
  [AC_REQUIRE([ACX_PROG_CLAW])dnl
   AC_LANG_ASSERT([Fortran])dnl
   AC_MSG_CHECKING([whether $CLAW accepts $1])
   m4_ifnblank([$4],
     [AC_CACHE_VAL([$4],
        [_ACX_CLAW_ACCEPTS([$1])
         AS_VAR_COPY([$4], [acx_claw_accepts])])
      AS_VAR_COPY([acx_claw_accepts], [$4])],
     [_ACX_CLAW_ACCEPTS([$1])])
   AC_MSG_RESULT([$acx_claw_accepts])
   AS_VAR_IF([acx_claw_accepts], [yes], [$2],
     [m4_default([$3],
        [AC_MSG_FAILURE(
        [CLAW preprocessor does not accept $1])])])])

# _ACX_CLAW_ACCEPTS([CLAWFLAGS])
# -----------------------------------------------------------------------------
# Checks whether the CLAW preprocessor accepts CLAWFLAGS. The result is either
# "yes" or "no".
#
# The result is stored in the acx_claw_accepts variable.
#
m4_define([_ACX_CLAW_ACCEPTS],
  [acx_claw_accepts=no
   AS_MKDIR_P([conftest.dir])
   cd conftest.dir
   AC_LANG_CONFTEST([AC_LANG_PROGRAM])
   AC_TRY_COMMAND([$CLAW -f -o conftest.claw.$ac_ext $CLAWFLAGS $1 dnl
conftest.$ac_ext >&AS_MESSAGE_LOG_FD])
   AS_IF([test $ac_status -eq 0], [acx_claw_accepts=yes])
   cd ..
   rm -rf conftest.dir])
