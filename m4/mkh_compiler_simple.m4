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

# MKH_COMPILER_FC_VENDOR_SIMPLE()
# -----------------------------------------------------------------------------
# Detects the vendor of the Fortran compiler. The result is "intel", "nag",
# "portland", "cray", "nec", "gnu", "amd", "flang" or "unknown".
#
# This is a simplified version MKH_COMPILER_FC_VENDOR, which tries to detect
# the vendor based on the version output of the compiler, instead of checking
# whether vendor-specific macros are defined.
#
# The result is cached in the mkh_cv_fc_compiler_vendor variable.
#
AC_DEFUN([MKH_COMPILER_FC_VENDOR_SIMPLE],
  [AC_LANG_ASSERT([Fortran])dnl
   m4_provide([MKH_COMPILER_FC_VENDOR])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler vendor], [mkh_cache_var],
     [AS_IF(
        [AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
grep '^\(ifort\|ifx\) (IFORT)' >/dev/null 2>&1],
        [mkh_cache_var=intel],
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
grep '^NAG Fortran Compiler Release' >/dev/null 2>&1],
        [mkh_cache_var=nag],
        [AS_VAR_GET([_AC_CC]) -V 2>/dev/null| dnl
grep '^Copyright.*\(The Portland Group\|NVIDIA CORPORATION\)' >/dev/null 2>&1],
        [mkh_cache_var=portland],
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | grep '^Cray Fortran' >/dev/null 2>&1],
        [mkh_cache_var=cray],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^Copyright.*NEC Corporation' >/dev/null 2>&1],
        [mkh_cache_var=nec],
        [AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
grep '^GNU Fortran' >/dev/null 2>&1],
        [mkh_cache_var=gnu],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^AMD clang version' >/dev/null 2>&1],
        [mkh_cache_var=amd],
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | grep '^f18 compiler' >/dev/null 2>&1],
        [mkh_cache_var=flang],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep 'clang version' >/dev/null 2>&1],
        [mkh_cache_var=flang],
        [mkh_cache_var=unknown])
      rm -f a.out a.out.dSYM a.exe b.out])
   m4_popdef([mkh_cache_var])])

# MKH_COMPILER_FC_VERSION_SIMPLE()
# -----------------------------------------------------------------------------
# Detects the version of the C compiler. The result is either "unknown"
# or a string in the form "[epoch:]major[.minor[.patchversion]]", where
# "epoch:" is an optional prefix used in order to have an increasing version
# number in case of marketing change.
#
# This is a simplified version MKH_COMPILER_FC_VERSION, which tries to detect
# the version based on the version output of the compiler, instead of checking
# for the values of vendor-specific macros.
#
# The result is cached in the mkh_cv_fc_compiler_version variable.
#
AC_DEFUN([MKH_COMPILER_FC_VERSION_SIMPLE],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([MKH_COMPILER_FC_VENDOR])dnl
   m4_provide([MKH_COMPILER_FC_VERSION])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_[]_AC_LANG_ABBREV[]_compiler_version])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler version], [mkh_cache_var],
     [AS_CASE([AS_VAR_GET([mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
        [intel],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/^ifort (IFORT) \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="classic:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/^ifx (IFORT) \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="oneapi:${mkh_cache_var}"])])],
        [nag],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
[sed -n 's/^NAG Fortran Compiler Release \([0-9][0-9]*\.[0-9][0-9]*\).*]dnl
[Build \([0-9][0-9]*\)/\1.\2/p']`],
        [portland],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>/dev/null | dnl
[sed -n 's/\(pgfortran\|pgf90\) \([0-9][0-9]*\.[0-9][0-9]*\)-\([0-9][0-9]*\).*/\2.\3/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="pg:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>/dev/null | dnl
[sed -n 's/nvfortran \([0-9][0-9]*\.[0-9][0-9]*\)-\([0-9][0-9]*\).*/\1.\2/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="nv:${mkh_cache_var}"])])],
        [cray],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
[sed -n 's/.*[vV]ersion \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`],
        [nec],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
[sed -n 's/^nfort (NFORT) \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`],
        [gnu],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -dumpfullversion 2>/dev/null | dnl
[sed -n '/^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/p']`
         AS_IF([test -z "$mkh_cache_var"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -dumpversion 2>/dev/null | dnl
[sed -n '/^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/p']`])],
        [amd],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/.*AOCC_\([0-9][0-9]*\)[._]\([0-9][0-9]*\)[._]\([0-9][0-9]*\).*/\1.\2.\3/p']`],
        [flang],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
[sed -n 's/.*version \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)/\1/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="f18:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/.*version \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="classic:${mkh_cache_var}"])])],
        [mkh_cache_var=unknown])
      rm -f a.out a.out.dSYM a.exe b.out
      AS_IF([test -z "$mkh_cache_var"], [mkh_cache_var=unknown])])
   m4_popdef([mkh_cache_var])])

# MKH_COMPILER_CC_VENDOR_SIMPLE()
# -----------------------------------------------------------------------------
# Detects the vendor of the C compiler. The result is  "intel", "nag",
# "portland", "cray", "nec", "gnu", "amd", "clang" or "unknown".
#
# This is a simplified version MKH_COMPILER_CC_VENDOR, which tries to detect
# the vendor based on the version output of the compiler, instead of checking
# whether vendor-specific macros are defined.
#
# The result is cached in the mkh_cv_c_compiler_vendor variable.
#
AC_DEFUN([MKH_COMPILER_CC_VENDOR_SIMPLE],
  [AC_LANG_ASSERT([C])dnl
   m4_provide([MKH_COMPILER_CC_VENDOR])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler vendor], [mkh_cache_var],
     [AS_IF(
        [AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
grep '^icc (ICC)' >/dev/null 2>&1],
        [mkh_cache_var=intel],
        [AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
grep '^Intel.*oneAPI.*Compiler' >/dev/null 2>&1],
        [mkh_cache_var=intel],
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
grep '^NAG Fortran Compiler Release' >/dev/null 2>&1],
        [mkh_cache_var=nag],
        [AS_VAR_GET([_AC_CC]) -V 2>/dev/null| dnl
grep '^Copyright.*\(The Portland Group\|NVIDIA CORPORATION\)' >/dev/null 2>&1],
        [mkh_cache_var=portland],
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | grep '^Cray C' >/dev/null 2>&1],
        [mkh_cache_var=cray],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^Cray clang' >/dev/null 2>&1],
        [mkh_cache_var=cray],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^Copyright.*NEC Corporation' >/dev/null 2>&1],
        [mkh_cache_var=nec],
        [AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
grep '^gcc' >/dev/null 2>&1],
        [mkh_cache_var=gnu],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^AMD clang version' >/dev/null 2>&1],
        [mkh_cache_var=amd],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^Apple \(LLVM\|clang\) version' >/dev/null 2>&1],
        [mkh_cache_var=apple],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep 'clang version' >/dev/null 2>&1],
        [mkh_cache_var=clang],
        [mkh_cache_var=unknown])
      rm -f a.out a.out.dSYM a.exe b.out])
   m4_popdef([mkh_cache_var])])

# MKH_COMPILER_CC_VERSION_SIMPLE()
# -----------------------------------------------------------------------------
# Detects the version of the C compiler. The result is either "unknown"
# or a string in the form "[epoch:]major[.minor[.patchversion]]", where
# "epoch:" is an optional prefix used in order to have an increasing version
# number in case of marketing change.
#
# This is a simplified version MKH_COMPILER_CC_VERSION, which tries to detect
# the version based on the version output of the compiler, instead of checking
# for the values of vendor-specific macros.
#
# The result is cached in the mkh_cv_c_compiler_version variable.
#
AC_DEFUN([MKH_COMPILER_CC_VERSION_SIMPLE],
  [AC_LANG_ASSERT([C])dnl
   AC_REQUIRE([MKH_COMPILER_CC_VENDOR])dnl
   m4_provide([MKH_COMPILER_CC_VERSION])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_[]_AC_LANG_ABBREV[]_compiler_version])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler version], [mkh_cache_var],
     [AS_CASE([AS_VAR_GET([mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
        [intel],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/^icc (ICC) \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="classic:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/^Intel.*oneAPI.*Compiler \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="oneapi:${mkh_cache_var}"])])],
        [nag],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
[sed -n 's/^NAG Fortran Compiler Release \([0-9][0-9]*\.[0-9][0-9]*\).*]dnl
[Build \([0-9][0-9]*\)/\1.\2/p']`],
        [portland],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>/dev/null | dnl
[sed -n 's/pgcc \((.*) \)\?\([0-9][0-9]*\.[0-9][0-9]*\)-\([0-9][0-9]*\).*/\2.\3/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="pg:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>/dev/null | dnl
[sed -n 's/nvc \([0-9][0-9]*\.[0-9][0-9]*\)-\([0-9][0-9]*\).*/\1.\2/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="nv:${mkh_cache_var}"])])],
        [cray],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
[sed -n 's/.*ersion \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
         AS_IF([test -n "$mkh_cache_var"],
           [mkh_cache_var="classic:${mkh_cache_var}"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version | dnl
[sed -n 's/.*version \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`
            AS_IF([test -n "$mkh_cache_var"],
              [mkh_cache_var="clang:${mkh_cache_var}"])])],
        [nec],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
[sed -n 's/^ncc (NCC) \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`],
        [gnu],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -dumpfullversion 2>/dev/null | dnl
[sed -n '/^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/p']`
         AS_IF([test -z "$mkh_cache_var"],
           [mkh_cache_var=`AS_VAR_GET([_AC_CC]) -dumpversion 2>/dev/null | dnl
[sed -n '/^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$/p']`])],
        [amd],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/.*AOCC_\([0-9][0-9]*\)[._]\([0-9][0-9]*\)[._]\([0-9][0-9]*\).*/\1.\2.\3/p']`],
        [apple],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -E -n 's/^Apple (LLVM|clang) version ([0-9]+\.[0-9]+\.[0-9]+).*/\2/p']`],
        [clang],
        [mkh_cache_var=`AS_VAR_GET([_AC_CC]) --version 2>/dev/null | dnl
[sed -n 's/.*clang version \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p']`],
        [mkh_cache_var=unknown])
      rm -f a.out a.out.dSYM a.exe b.out
      AS_IF([test -z "$mkh_cache_var"], [mkh_cache_var=unknown])])
   m4_popdef([mkh_cache_var])])
