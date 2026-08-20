# Copyright (c) 2018-2026, MPI-M
#
# Author: Sergey Kosukhin <sergey.kosukhin@mpimet.mpg.de>
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# MKH_FC_MODULE_IN_FLAG([ACTION-IF-SUCCESS],
#                       [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify module search paths.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the mkh_cv_fc_module_in_flag variable, which may
# contain a significant trailing whitespace.
#
# The implementation patches the standard Autoconf macro AC_FC_MODULE_FLAG to
# reduce the number of LANG switches and to avoid false negative results with
# the GFortran '-fmodule-private' flag.
#
AC_DEFUN([MKH_FC_MODULE_IN_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   m4_pushdef([ac_cv_fc_module_flag], [mkh_cv_fc_module_in_flag])dnl
   m4_pushdef([AC_CACHE_CHECK],
     m4_bpatsubst(m4_dquote(m4_defn([AC_CACHE_CHECK])),
       [\$][1],
       [for Fortran compiler flag needed to specify search paths for module dnl
files]))dnl
   m4_pushdef([AC_SUBST], [dn][l ])dnl
   m4_pushdef([AC_CONFIG_COMMANDS_PRE], [dn][l ])dnl
   m4_pushdef([mkh_orig_macro],
     m4_bpatsubsts(m4_dquote(m4_defn([AC_FC_MODULE_FLAG])),
       [^      module conftest_module], [\&
      implicit none
      public],
       [^      use conftest_module], [\&, only : conftest_routine
      implicit none],
       [AC_LANG_P\(OP\|USH\)(\[?Fortran\]?)], [dn][l ],
       [FC_MODINC=.*], [dn][l ],
       [^ *#], [dn][l ]))dnl
   mkh_orig_macro([:], [:])dnl
   m4_popdef([mkh_orig_macro])dnl
   m4_popdef([AC_SUBST])dnl
   m4_popdef([AC_CONFIG_COMMANDS_PRE])dnl
   m4_popdef([AC_CACHE_CHECK])dnl
   m4_popdef([ac_cv_fc_module_flag])dnl
   AS_VAR_IF([mkh_cv_fc_module_in_flag], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect Fortran compiler flag needed to dnl
specify search paths for module files])])], [$1])])

# MKH_FC_MODULE_OUT_FLAG([ACTION-IF-SUCCESS],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to specify module output path.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the mkh_cv_fc_module_out_flag variable, which may
# contain a significant trailing whitespace.
#
# The implementation patches the standard Autoconf macro
# AC_FC_MODULE_OUTPUT_FLAG to reduce the number of LANG switches and to avoid
# false negative results with the GFortran '-fmodule-private' flag.
#
AC_DEFUN([MKH_FC_MODULE_OUT_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   m4_pushdef([ac_cv_fc_module_output_flag], [mkh_cv_fc_module_out_flag])dnl
   m4_pushdef([AC_CACHE_CHECK],
     m4_bpatsubst(m4_dquote(m4_defn([AC_CACHE_CHECK])),
       [\$][1],
       [for Fortran compiler flag needed to specify output path for module dnl
files]))dnl
   m4_pushdef([AC_SUBST], [dn][l ])dnl
   m4_pushdef([AC_CONFIG_COMMANDS_PRE], [dn][l ])dnl
   m4_pushdef([mkh_orig_macro],
     m4_bpatsubsts(m4_dquote(m4_defn([AC_FC_MODULE_OUTPUT_FLAG])),
       [^      module conftest_module], [\&
      implicit none
      public],
       [^      use conftest_module], [\&, only : conftest_routine
      implicit none],
       [AC_LANG_P\(OP\|USH\)(\[?Fortran\]?)], [dn][l ],
       [FC_MODOUT=.*], [dn][l ],
       [^ *#], [dn][l ]))dnl
   m4_version_prereq([2.70], [],
     [m4_define([mkh_orig_macro],
        m4_bpatsubsts(m4_dquote(m4_defn([mkh_orig_macro])),
          ['-mod '], ['-mdir ' \&],))])dnl
   mkh_orig_macro([:], [:])dnl
   m4_popdef([mkh_orig_macro])dnl
   m4_popdef([AC_SUBST])dnl
   m4_popdef([AC_CONFIG_COMMANDS_PRE])dnl
   m4_popdef([AC_CACHE_CHECK])dnl
   m4_popdef([ac_cv_fc_module_output_flag])dnl
   AS_VAR_IF([mkh_cv_fc_module_out_flag], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect Fortran compiler flag needed to dnl
specify output path for module files])])], [$1])])

# MKH_FC_MODULE_NAMING([ACTION-IF-SUCCESS],
#                      [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler module file naming template.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_fc_module_naming_upper and
# mkh_cv_fc_module_naming_ext variables. If output module files have uppercase
# names, mkh_cv_fc_module_naming_upper is "yes", and "no" otherwise. The
# mkh_cv_fc_module_naming_ext variable stores the file extension without the
# leading dot. Either of the variables can have value "unknown". The result is
# successful only if both variables are detected.
#
AC_DEFUN([MKH_FC_MODULE_NAMING],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_MSG_CHECKING([for Fortran compiler module file naming template])
   AS_IF([AS_VAR_TEST_SET([mkh_cv_fc_module_naming_upper]) && dnl
AS_VAR_TEST_SET([mkh_cv_fc_module_naming_ext])],
     [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
     [mkh_cv_fc_module_naming_upper=${mkh_cv_fc_module_naming_upper-unknown}
      mkh_cv_fc_module_naming_ext=${mkh_cv_fc_module_naming_ext-unknown}
      AS_MKDIR_P([conftest.dir])
      cd conftest.dir
      AC_COMPILE_IFELSE([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      contains
      subroutine conftest_routine
      end subroutine
      end module]])],
        [AS_CASE([$mkh_cv_fc_module_naming_upper],
           [yes], [mkh_tmp='CONFTEST_MODULE.*'],
           [no], [mkh_tmp='conftest_module.*'],
           [AS_VAR_IF([mkh_cv_fc_module_naming_ext], [unknown],
              [mkh_tmp='CONFTEST_MODULE.* conftest_module.*'],
              [mkh_tmp="CONFTEST_MODULE.$mkh_cv_fc_module_naming_ext dnl
conftest_module.$mkh_cv_fc_module_naming_ext"])])
         mkh_tmp=`ls $mkh_tmp 2>/dev/null`
         AS_IF([test 1 -eq `AS_ECHO(["$mkh_tmp"]) | wc -l` 2>/dev/null],
           [AS_CASE(["$mkh_tmp"],
              [CONFTEST_MODULE.*],
              [mkh_cv_fc_module_naming_upper=yes
               mkh_cv_fc_module_naming_ext=`echo $mkh_tmp | dnl
sed 's,CONFTEST_MODULE\.,,'`],
              [conftest_module.*],
              [mkh_cv_fc_module_naming_upper=no
               mkh_cv_fc_module_naming_ext=`echo $mkh_tmp | dnl
sed 's,conftest_module\.,,'`])])])
      cd ..
      rm -rf conftest.dir])
   AS_IF([test "x$mkh_cv_fc_module_naming_upper" = xunknown || dnl
test "x$mkh_cv_fc_module_naming_ext" = xunknown],
     [AC_MSG_RESULT([unknown])
      m4_default([$2], [AC_MSG_FAILURE([unable to detect Fortran compiler dnl
module file naming template])])],
     [AS_VAR_IF([mkh_cv_fc_module_naming_upper], [yes],
        [AC_MSG_RESULT([{NAME}.$mkh_cv_fc_module_naming_ext])],
        [AC_MSG_RESULT([{name}.$mkh_cv_fc_module_naming_ext])])
      $1])])

# MKH_FC_MODULE_SNAMING([ACTION-IF-SUCCESS],
#                       [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler submodule file naming template.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_fc_module_snaming_infix and
# mkh_cv_fc_module_snaming_ext variables. If output submodule files are
# prefixed with the names of the modules they extend (root ancestors),
# mkh_cv_fc_module_snaming_infix is set to a non-empty string that the compiler
# injects between the name of the root ancestor and the submodule name in the
# submodule filename. Otherwise, mkh_cv_fc_module_snaming_infix is set to an
# empty string. The mkh_cv_fc_module_snaming_ext variable stores the file
# extension without the leading dot. Either of the variables can have value
# "unknown". The result is successful only if both variables are detected.
#
AC_DEFUN([MKH_FC_MODULE_SNAMING],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([MKH_FC_MODULE_NAMING])dnl
   AC_MSG_CHECKING([for Fortran compiler submodule file naming template])
   AS_IF([AS_VAR_TEST_SET([mkh_cv_fc_module_snaming_infix]) && dnl
AS_VAR_TEST_SET([mkh_cv_fc_module_snaming_ext])],
     [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
     [mkh_cv_fc_module_snaming_infix=dnl
${mkh_cv_fc_module_snaming_infix-unknown}
      mkh_cv_fc_module_snaming_ext=${mkh_cv_fc_module_snaming_ext-unknown}
      AS_MKDIR_P([conftest.dir])
      cd conftest.dir
      AC_COMPILE_IFELSE([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      interface
      module subroutine conftest_routine
      end subroutine
      end interface
      end module
      submodule (conftest_module) conftest_submodule
      implicit none
      contains
      module subroutine conftest_routine
      end subroutine
      end submodule]])],
        [AS_VAR_IF([mkh_cv_fc_module_naming_upper], [yes],
           [mkh_fc_module_name='CONFTEST_MODULE'
            mkh_fc_module_sname='CONFTEST_SUBMODULE'],
           [mkh_fc_module_name='conftest_module'
            mkh_fc_module_sname='conftest_submodule'])
         AS_VAR_IF([mkh_cv_fc_module_snaming_infix], [unknown],
           [mkh_tmp='*'],
           [mkh_tmp="${mkh_fc_module_name}$mkh_cv_fc_module_snaming_infix"])
         AS_VAR_APPEND([mkh_tmp], ["$mkh_fc_module_sname."])
         AS_VAR_IF([mkh_cv_fc_module_snaming_ext], [unknown],
           [AS_VAR_APPEND([mkh_tmp], '*')],
           [AS_VAR_APPEND([mkh_tmp], ["$mkh_cv_fc_module_snaming_ext"])])
         mkh_tmp=`ls $mkh_tmp 2>/dev/null`
         AS_IF([test 1 -eq `AS_ECHO(["$mkh_tmp"]) | wc -l` 2>/dev/null],
           [AS_VAR_IF([mkh_cv_fc_module_snaming_ext], [unknown],
              [AS_CASE([$mkh_tmp],
                 [*"$mkh_fc_module_sname."*],
                 [mkh_cv_fc_module_snaming_ext=`echo $mkh_tmp | dnl
sed "s,.*$mkh_fc_module_sname\.,,"`])])
            AS_VAR_IF([mkh_cv_fc_module_snaming_infix], [unknown],
              [AS_CASE([$mkh_tmp],
                 ["$mkh_fc_module_sname."*],
                 [mkh_cv_fc_module_snaming_infix=],
                 ["$mkh_fc_module_name"*"$mkh_fc_module_sname"*],
                 [mkh_cv_fc_module_snaming_infix=`echo $mkh_tmp | dnl
sed "s,$mkh_fc_module_sname\..*,," | sed "s,^$mkh_fc_module_name,,"`])])])])
      cd ..
      rm -rf conftest.dir])
   AS_IF([test "x$mkh_cv_fc_module_snaming_infix" = xunknown || dnl
test "x$mkh_cv_fc_module_snaming_ext" = xunknown],
     [AC_MSG_RESULT([unknown])
      m4_default([$2], [AC_MSG_FAILURE([unable to detect Fortran compiler dnl
submodule file naming template])])],
     [AS_VAR_IF([mkh_cv_fc_module_naming_upper], [yes],
        [mkh_fc_module_name='{NAME}'
         mkh_fc_module_sname='{SNAME}'],
        [mkh_fc_module_name='{name}'
         mkh_fc_module_sname='{sname}'])
      AS_VAR_IF([mkh_cv_fc_module_snaming_infix], [],
        [mkh_tmp=],
        [mkh_tmp="$mkh_fc_module_name$mkh_cv_fc_module_snaming_infix"])
      AC_MSG_RESULT(
        [$mkh_tmp$mkh_fc_module_sname.$mkh_cv_fc_module_snaming_ext])
      $1])])

# MKH_FC_MODULE_ROOT_SMOD([ACTION-IF-SUCCESS],
#                         [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler generates separate submodule files for
# the root ancestor modules.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_fc_module_root_smod variable. If the
# compiler generates separate submodule files for the root ancestor modules,
# mkh_cv_fc_module_root_smod is "yes", and "no" otherwise. If the detection
# fails, mkh_cv_fc_module_root_smod is set to "unknown".
#
AC_DEFUN([MKH_FC_MODULE_ROOT_SMOD],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([MKH_FC_MODULE_NAMING])dnl
   AC_REQUIRE([MKH_FC_MODULE_SNAMING])dnl
   AC_CACHE_CHECK(
     [whether Fortran compiler generates submodule files for root ancestors],
     [mkh_cv_fc_module_root_smod],
     [mkh_cv_fc_module_root_smod=unknown
      AS_VAR_IF([mkh_cv_fc_module_snaming_ext],
        ["$mkh_cv_fc_module_naming_ext"],
        [mkh_cv_fc_module_root_smod=no],
        [AS_MKDIR_P([conftest.dir])
         cd conftest.dir
         AC_COMPILE_IFELSE([AC_LANG_SOURCE(
[[      module conftest_module
      implicit none
      public
      interface
      module subroutine conftest_routine
      end subroutine
      end interface
      end module]])],
           [AS_VAR_IF([mkh_cv_fc_module_naming_upper], [yes],
              [mkh_fc_module_name='CONFTEST_MODULE'],
              [mkh_fc_module_name='conftest_module'])
            AS_IF(
              [test -f "$mkh_fc_module_name.$mkh_cv_fc_module_snaming_ext"],
              [mkh_cv_fc_module_root_smod=yes],
              [mkh_cv_fc_module_root_smod=no])])
         cd ..
         rm -rf conftest.dir])])
   AS_VAR_IF([mkh_cv_fc_module_root_smod], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect whether Fortran compiler generates dnl
submodule files for modules])])], [$1])])

# MKH_FC_MODULE_CHECK(MODULE-NAME,
#                     [ACTION-IF-SUCCESS],
#                     [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran module MODULE-NAME is available. The result is
# either "yes" or "no".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_fc_module_[]AS_TR_CPP(MODULE-NAME)
# variable.
#
AC_DEFUN([MKH_FC_MODULE_CHECK],
  [AC_LANG_ASSERT([Fortran])dnl
   m4_pushdef([mkh_cache_var], [mkh_cv_fc_module_[]AS_TR_CPP([$1])])dnl
   AC_CACHE_CHECK([for Fortran module AS_TR_CPP([$1])], [mkh_cache_var],
     [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[      use $1]])],
        [AS_VAR_SET([mkh_cache_var], [yes])],
        [AS_VAR_SET([mkh_cache_var], [no])])])
   AS_VAR_IF([mkh_cache_var], [yes], [$2], [m4_default([$3],
     [AC_MSG_FAILURE([Fortran module 'AS_TR_CPP([$1])' is not available])])])
   m4_popdef([mkh_cache_var])])

# MKH_FC_MODULE_PROC_CHECK(MODULE-NAME,
#                          PROCEDURE-NAME,
#                          [CALL-CODE = "      CALL PROCEDURE-NAME()"],
#                          [ACTION-IF-SUCCESS],
#                          [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran module procedure PROCEDURE-NAME from the module
# MODULE-NAME is available. The check is performed by linking a program that
# uses the module MODULE-NAME as "USE MODULE-NAME, ONLY : PROCEDURE-NAME"
# followed by the "IMPLICIT NONE" statement and the CALL-CODE (defaults to
# calling the PROCEDURE-NAME without parameters, which means that if
# PROCEDURE-NAME is a function or a subroutine with parameters, the CALL-CODE
# must be provided). The result is either "yes" or "no".
#
# If successful, runs ACTION-IF-SUCCESS (defaults to nothing), otherwise runs
# ACTION-IF-FAILURE (defaults to failing with an error message).
#
# The result is cached in the
# mkh_cv_fc_module_proc_[]AS_TR_CPP(MODULE-NAME)_[]AS_TR_CPP(PROCEDURE-NAME)
# variable.
#
AC_DEFUN([MKH_FC_MODULE_PROC_CHECK],
  [AC_LANG_ASSERT([Fortran])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_fc_module_proc_[]AS_TR_CPP([$1])_[]AS_TR_CPP([$2])])dnl
   AC_CACHE_CHECK([for Fortran procedure AS_TR_CPP([$2]) from module dnl
AS_TR_CPP([$1])],
     [mkh_cache_var],
     [AC_LINK_IFELSE([AC_LANG_PROGRAM([],[[      use $1, only : $2
      implicit none]
m4_default([$3], [[      call $2 ()]])])],
        [AS_VAR_SET([mkh_cache_var], [yes])],
        [AS_VAR_SET([mkh_cache_var], [no])])])
   AS_VAR_IF([mkh_cache_var], [yes], [$4], [m4_default([$5],
     [AC_MSG_FAILURE([Fortran module procedure 'AS_TR_CPP([$2])' from dnl
module 'AS_TR_CPP([$1])' is not available])])])
   m4_popdef([mkh_cache_var])])

# MKH_FC_MODULE_ONLY_FLAG([ACTION-IF-SUCCESS],
#                         [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the Fortran compiler flag needed to generate module files but no object
# files. The result is either "unknown" or the actual compiler flag (might be a
# space-separated combination of several flags).
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the mkh_cv_fc_module_only_flag variable.
#
# Known flags:
# Intel: -syntax-only (or -fsyntax-only)
# GNU: -fsyntax-only
# NEC: -fsyntax-only
# PGI/NVIDIA: -Msyntax-only
# NAG: -M or -otype=mod
# Cray: '-dB -M2179' (the second flag suppresses an excessive warning)
#       or -otype=mod (undocumented and slow)
#
AC_DEFUN([MKH_FC_MODULE_ONLY_FLAG],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([MKH_FC_MODULE_NAMING])dnl
   AC_CACHE_CHECK(
     [for Fortran compiler flag needed to generate module files but no dnl
object files],
     [mkh_cv_fc_module_only_flag],
     [mkh_cv_fc_module_only_flag=unknown
      AS_MKDIR_P([conftest.dir])
      cd conftest.dir
      AC_LANG_CONFTEST([AC_LANG_SOURCE(
[[      module conftest_module
      end module]])])
      AS_VAR_IF([mkh_cv_fc_module_naming_upper], [yes],
        [mkh_tmp="CONFTEST_MODULE.$mkh_cv_fc_module_naming_ext"],
        [mkh_tmp="conftest_module.$mkh_cv_fc_module_naming_ext"])
      mkh_save_FCFLAGS=$FCFLAGS
      for mkh_flag in '-syntax-only' '-fsyntax-only' '-Msyntax-only' dnl
'-dB -M2179' '-M' '-otype=mod'; do
        FCFLAGS="$mkh_save_FCFLAGS $mkh_flag"
        AS_IF([_AC_DO_VAR([ac_compile]) && dnl
test -f $mkh_tmp && test ! -f conftest.$ac_objext],
          [mkh_cv_fc_module_only_flag=$mkh_flag; break],
          [rm -f $mkh_tmp conftest.$ac_objext])
      done
      FCFLAGS=$mkh_save_FCFLAGS
      cd ..
      rm -rf conftest.dir])
   AS_VAR_IF([mkh_cv_fc_module_only_flag], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect Fortran compiler flag needed to dnl
generate module files but no object files])])], [$1])])
