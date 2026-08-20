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

# AC_LANG([CUDA])
# -----------------------------------------------------------------------------
# Define language CUDA with _AC_LANG_ABBREV set to "cuda", _AC_LANG_PREFIX set
# to "CUDA" (i.e. _AC_LANG_PREFIX[]FLAGS equals to 'CUDAFLAGS'), _AC_CC set to
# "CUDACXX", and various language-specific Autoconf macros (e.g.
# AC_LANG_SOURCE) copied from C++ language.
#
AC_LANG_DEFINE([CUDA], [cuda], [CUDA], [CUDACXX], [C++],
[ac_ext=cu
ac_compile='$CUDACXX -c $CUDAFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_link='$CUDACXX -o conftest$ac_exeext $CUDAFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&AS_MESSAGE_LOG_FD'
ac_compiler_gnu=$mkh_cv_cuda_compiler_gnu
])
dnl Avoid mixing macro definitions that are relevant for C or C++ compiler and
dnl might be irrelevant for CUDA:
m4_copy_force([AC_LANG_CONFTEST()], [AC_LANG_CONFTEST(CUDA)])
AC_DEFUN([AC_LANG_COMPILER(CUDA)], [AC_REQUIRE([MKH_PROG_CUDACXX])])

# MKH_LANG_CUDA()
# MKH_LANG_PUSH_CUDA()
# MKH_LANG_POP_CUDA()
# -----------------------------------------------------------------------------
# A set of macros wrapping AC_LANG([CUDA]), AC_LANG_PUSH([CUDA]), and
# AC_LANG_POP([CUDA]), respectively, that can be used in the "configure.ac"
# to switch to/from CUDA language without the need to call "aclocal/autoreconf"
# with additional flag "-I /path/to/dir/with/this/file". Useful for projects
# that do not use Automake for the makefile generation and, therefore, cannot
# specify "ACLOCAL_AMFLAGS" in the top-level "Makefile.am".
#
AC_DEFUN([MKH_LANG_CUDA], [AC_LANG([CUDA])])
AC_DEFUN([MKH_LANG_PUSH_CUDA], [AC_LANG_PUSH([CUDA])])
AC_DEFUN([MKH_LANG_POP_CUDA], [AC_LANG_POP([CUDA])])

# MKH_PROG_CUDACXX([LIST-OF-COMPILERS = nvcc])
# -----------------------------------------------------------------------------
# Searches for the CUDA C++ compiler command among the values of the
# blank-separated list LIST-OF-COMPILERS (defaults to a single value "nvcc").
# Declares precious variables CUDACXX and CUDAFLAGS to be set to the compiler
# command and the compiler flags, respectively. If the environment variable
# CUDACXX is set, values of the list LIST-OF-COMPILERS are ignored.
#
# Checks whether the compiler supports an ISO C++ standard and/or whether it
# can compile a basic CUDA program. The result of the check is stored in the
# shell variable mkh_prog_cudacxx_works, which can be either "cxx14", (ISO C++
# 2014, ISO C++ 2011 and the basic CUDA features are supported), "cxx11" (ISO
# C++ 2011 and the basic CUDA features are supported), "basic" (only the basic
# CUDA features are supported) and "no" (the compiler cannot compile even the
# basic CUDA program). If the compiler supports the C++ standard, the flag that
# is required to enable it is cached in the
# mkh_cv_prog_cudacxx_${mkh_prog_cudacxx_works}_flag variable. The users are
# expected to either append the flag to CUDACXX or prepended it to CUDAFLAGS
# based on the value of the mkh_prog_cudacxx_works shell variable.
#
AC_DEFUN_ONCE([MKH_PROG_CUDACXX],
  [AC_LANG_PUSH([CUDA])dnl
   AC_ARG_VAR([CUDACXX], [CUDA C++ compiler command])dnl
   AC_ARG_VAR([CUDAFLAGS], [CUDA C++ compiler flags])dnl
   _AC_ARG_VAR_LDFLAGS()dnl
   _AC_ARG_VAR_LIBS()dnl
   AS_IF([test -z "$CUDACXX"],
     [AC_CHECK_PROGS([CUDACXX], [m4_default([$1], [nvcc])])])
   _AS_ECHO_LOG([checking for CUDA C++ compiler version])
   set dummy $ac_compile
   ac_compiler=$[2]
   _AC_DO_LIMIT([$ac_compiler --version >&AS_MESSAGE_LOG_FD])
   m4_expand_once([_AC_COMPILER_EXEEXT])[]dnl
   m4_expand_once([_AC_COMPILER_OBJEXT])[]dnl
   _AC_LANG_COMPILER_GNU
   mkh_test_CUDAFLAGS=${CUDAFLAGS+set}
   mkh_save_CUDAFLAGS=$CUDAFLAGS
   AC_CACHE_CHECK([whether $CUDACXX accepts -g], [mkh_cv_prog_cudac_g],
     [mkh_save_cuda_werror_flag=$ac_cuda_werror_flag
      ac_cuda_werror_flag=yes
      mkh_cv_prog_cudac_g=no
      CUDAFLAGS='-g'
      _AC_COMPILE_IFELSE([AC_LANG_PROGRAM],
        [mkh_cv_prog_cudac_g=yes],
        [CUDAFLAGS=''
         _AC_COMPILE_IFELSE([AC_LANG_PROGRAM],
           [],
           [ac_cuda_werror_flag=$mkh_save_cuda_werror_flag
            CUDAFLAGS='-g'
            _AC_COMPILE_IFELSE([AC_LANG_PROGRAM],
              [mkh_cv_prog_cudac_g=yes])])])
      ac_cuda_werror_flag=$mkh_save_cuda_werror_flag])
   AS_IF(
     [test "$mkh_test_CUDAFLAGS" = set],
     [CUDAFLAGS=$mkh_save_CUDAFLAGS],
     [test "$mkh_cv_prog_cudac_g" = yes],
     [AS_VAR_IF([ac_cv_cuda_compiler_gnu], [yes],
        [CUDAFLAGS='-g -O2'], [CUDAFLAGS='-g'])],
     [AS_VAR_IF([ac_cv_cuda_compiler_gnu], [yes],
        [CUDAFLAGS='-O2'], [CUDAFLAGS=''])])
   mkh_prog_cudacxx_works=no
   m4_map_sep([_MKH_CUDA_CXX_TEST], [
], [[14],[11]])
   _MKH_CUDA_BASIC_TEST
   AC_LANG_POP([CUDA])])

# MKH_CUDACXX_LIBRARY_LDFLAGS()
# -----------------------------------------------------------------------------
# Determines the linker flags (e.g., -L and -l) for the CUDA runtime libraries
# that are required to successfully link a CUDA program. The result is set to
# these flags and should be included after LIBS when linking.
#
# The macro is intended to be used in those situations when a program contains
# CUDA objects but is linked with a compiler other than the CUDA C++ compiler.
# Note that the result does not contain runtime libraries of the host compiler.
#
# The result is cached in the mkh_cv_cudacxx_libs variable.
#
AC_DEFUN([MKH_CUDACXX_LIBRARY_LDFLAGS],
  [AC_REQUIRE([MKH_PROG_CUDACXX])dnl
   AC_LANG_PUSH([CUDA])
   AC_CACHE_CHECK([for CUDA libraries of $CUDACXX], [mkh_cv_cudacxx_libs],
     [mkh_cv_cudacxx_libs=
      AC_LANG_CONFTEST([AC_LANG_PROGRAM])
dnl Get the verbose output and remove the leading '#$ ':
      mkh_save_CUDAFLAGS=$CUDAFLAGS
      CUDAFLAGS="$CUDAFLAGS -v"
      mkh_cudacxx_v_output=`eval $ac_link AS_MESSAGE_LOG_FD>&1 2>&1 | dnl
[sed 's/^#\$ *//']`
      rm -f conftest*
      CUDAFLAGS=$mkh_save_CUDAFLAGS
dnl Get the value of the LIBRARIES variable, which will be our marker for the
dnl link command:
      mkh_cudacxx_link_marker=`AS_ECHO(["$mkh_cudacxx_v_output"]) | dnl
[sed -n 's/LIBRARIES= *\(.*\)/\1/p']`
dnl Remove all irrelevant lines from the output:
dnl   1) variable declarations;
dnl   2) lines starting with nvlink (contains the marker but is not what we
dnl      need).
      mkh_cudacxx_v_output=`AS_ECHO(["$mkh_cudacxx_v_output"]) | dnl
[sed '/^[^= ][^= ]*=.*/d;/^nvlink.*/d']`
dnl Find the link command(s):
      mkh_cudacxx_link_line=`AS_ECHO(["$mkh_cudacxx_v_output"]) | dnl
grep "$mkh_cudacxx_link_marker" | tr '\n' ' '`
dnl Extract the flags (currently, we take only -l and -L):
      eval "set dummy $mkh_cudacxx_link_line"; shift
      while test $[]@%:@ != 0; do
        AS_CASE([$[]1],
          [-[[lL]]],
          [AS_CASE([$[]2],
             ['' | -*], [],
             [AS_VAR_APPEND([mkh_cv_cudacxx_libs], [" $[]1$[]2"])
              shift])],
          [-[[lL]]*],
          [AS_VAR_APPEND([mkh_cv_cudacxx_libs], [" $[]1"])])
        shift
      done])
   AC_LANG_POP([CUDA])])

# _MKH_CUDA_CXX_TEST(STANDARD)
# -----------------------------------------------------------------------------
# Checks whether the CUDA C++ compiler supports the ISO C++ STANDARD (only
# checks for ISO C++ 2014 and ISO C++ 2011 are currently supported) and can
# compile a basic CUDA program. The value of STANDARD is expected to be the
# last two digits of the standard's year (e.g. 11). The check is skipped if the
# mkh_prog_cudacxx_works shell variable is set to a value other than "no" (in a
# normal scenario that means that a more recent ISO C++ standard is supported).
#
# If successful, sets the shell variable mkh_prog_cudacxx_works to
# "cxx[]STANDARD" (e.g. "cxx11") and the cache variable
# mkh_cv_prog_cudacxx_cxx[]STANDARD[]_flag to the flag that is required to
# enable the standard.
#
AC_DEFUN([_MKH_CUDA_CXX_TEST],
  [AC_LANG_ASSERT([CUDA])dnl
   AC_REQUIRE([_MKH_CUDA_CXX$1_TEST_PROGRAM])dnl
   AS_VAR_IF([mkh_prog_cudacxx_works], [no],
     [AC_MSG_CHECKING([for $CUDACXX option to enable C++$1 features])
      m4_pushdef([mkh_cache_var], [mkh_cv_prog_cudacxx_cxx$1_flag])dnl
      AC_CACHE_VAL([mkh_cache_var],
        [mkh_cache_var=unsupported
         AC_LANG_CONFTEST([$mkh_cuda_conftest_cxx$1_program])
         mkh_save_CUDAFLAGS=$CUDAFLAGS
         for mkh_flag in '' m4_normalize(m4_defn([_MKH_CUDA_CXX$1_OPTIONS]))
         do
           CUDAFLAGS="$mkh_flag $mkh_save_CUDAFLAGS"
           _AC_COMPILE_IFELSE([], [mkh_cache_var=$mkh_flag])
           test "x$mkh_cache_var" != xunsupported && break
         done
         CUDAFLAGS=$mkh_save_CUDAFLAGS
         rm -f conftest.$ac_ext])
      AS_IF([test -n "$mkh_cache_var"],
        [AC_MSG_RESULT([$mkh_cache_var])],
        [AC_MSG_RESULT([none needed])])
      AS_IF([test "x$mkh_cache_var" != xunsupported],
        [mkh_prog_cudacxx_works=cxx$1])
      m4_popdef([mkh_cache_var])])])

# _MKH_CUDA_BASIC_TEST()
# -----------------------------------------------------------------------------
# Checks whether the CUDA C++ compiler can compile a basic CUDA program. The
# check is skipped if the mkh_prog_cudacxx_works shell variable is set to a
# value other than "no" (in a normal scenario that means that the compiler
# supports an ISO C++ standard, as well as the basic CUDA features).
#
# If successful, sets the shell variable mkh_prog_cudacxx_works to "basic".
#
# The result is cached in the mkh_cv_prog_cudaxx_basic variable.
#
AC_DEFUN([_MKH_CUDA_BASIC_TEST],
  [AC_LANG_ASSERT([CUDA])dnl
   AC_REQUIRE([_MKH_CUDA_BASIC_TEST_PROGRAM])dnl
   AS_VAR_IF([mkh_prog_cudacxx_works], [no],
     [AC_CACHE_CHECK([whether $CUDACXX can compile basic CUDA code],
        [mkh_cv_prog_cudaxx_basic],
        [_AC_COMPILE_IFELSE([$mkh_cuda_conftest_basic_program],
           [mkh_cv_prog_cudaxx_basic=yes],
           [mkh_cv_prog_cudaxx_basic=no])])
      AS_VAR_IF([mkh_cv_prog_cudaxx_basic], [yes],
        [mkh_prog_cudacxx_works=basic])])])

# _MKH_CUDA_BASIC_TEST_GLOBALS()
# _MKH_CUDA_BASIC_TEST_MAIN()
# _MKH_CUDA_BASIC_TEST_PROGRAM()
# _MKH_CUDA_CXX11_TEST_GLOBALS()
# _MKH_CUDA_CXX11_TEST_MAIN()
# _MKH_CUDA_CXX11_TEST_PROGRAM()
# _MKH_CUDA_CXX14_TEST_GLOBALS()
# _MKH_CUDA_CXX14_TEST_MAIN()
# _MKH_CUDA_CXX14_TEST_PROGRAM()
# -----------------------------------------------------------------------------
# A set of macros that expand to the shell code in the INIT_PREPARE section of
# the configure script that assigns respective shell variables to the source
# code of the test programs that are used when checking for the CUDA C++
# compiler features.
#
AC_DEFUN([_MKH_CUDA_BASIC_TEST_GLOBALS],
  [m4_divert_once([INIT_PREPARE],
[[# Basic CUDA test code (global declarations):
mkh_cuda_conftest_basic_globals='#include <cuda.h>
__global__ void conftest_foo() {}'
]])])

AC_DEFUN([_MKH_CUDA_BASIC_TEST_MAIN],
  [m4_divert_once([INIT_PREPARE],
[[# Basic CUDA test code (body of main):
mkh_cuda_conftest_basic_main='conftest_foo<<<1, 1>>>();'
]])])

AC_DEFUN([_MKH_CUDA_BASIC_TEST_PROGRAM],
  [AC_REQUIRE([_MKH_CUDA_BASIC_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_BASIC_TEST_MAIN])dnl
   m4_divert_once([INIT_PREPARE],
[[# Basic CUDA test code (complete):
mkh_cuda_conftest_basic_program="$mkh_cuda_conftest_basic_globals
int main (int argc, char **argv)
{
  $mkh_cuda_conftest_basic_main
  return 0;
}
"
]])])

AC_DEFUN([_MKH_CUDA_CXX11_TEST_GLOBALS],
  [m4_divert_once([INIT_PREPARE],
[[# C++11 CUDA test code (global declarations):
mkh_cuda_conftest_cxx11_globals='
#if !defined __cplusplus || __cplusplus < 201103L
# error "Compiler does not advertise C++11 conformance"
#endif

namespace cxx11test {
  template<typename T>
  class ConftestClassCXX11 {
  public:
    void operator() (T elem) {}
  };
}'
]])])

AC_DEFUN([_MKH_CUDA_CXX11_TEST_MAIN],
  [m4_divert_once([INIT_PREPARE],
[[# C++11 CUDA test code (body of main):
mkh_cuda_conftest_cxx11_main='
int* pcxx11 = nullptr;
cxx11test::ConftestClassCXX11<int> some_class =
  cxx11test::ConftestClassCXX11<int>();
int icxx11 = 1;
pcxx11 = &icxx11;
some_class(*pcxx11);'
]])])

AC_DEFUN([_MKH_CUDA_CXX11_TEST_PROGRAM],
  [AC_REQUIRE([_MKH_CUDA_BASIC_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_BASIC_TEST_MAIN])dnl
   AC_REQUIRE([_MKH_CUDA_CXX11_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_CXX11_TEST_MAIN])dnl
   m4_divert_once([INIT_PREPARE],
[[# C++11 CUDA test code (complete):
mkh_cuda_conftest_cxx11_program="$mkh_cuda_conftest_basic_globals
$mkh_cuda_conftest_cxx11_globals
int main (int argc, char **argv)
{
  $mkh_cuda_conftest_basic_main
  $mkh_cuda_conftest_cxx11_main
  return 0;
}
"
]])])

AC_DEFUN([_MKH_CUDA_CXX14_TEST_GLOBALS],
  [m4_divert_once([INIT_PREPARE],
[[# C++14 CUDA test code (global declarations):
mkh_cuda_conftest_cxx14_globals='
#if !defined __cplusplus || __cplusplus < 201402L
# error "Compiler does not advertise C++14 conformance"
#endif
'
]])])

AC_DEFUN([_MKH_CUDA_CXX14_TEST_MAIN],
  [m4_divert_once([INIT_PREPARE],
[[# C++14 CUDA test code (body of main):
mkh_cuda_conftest_cxx14_main=''
]])])

AC_DEFUN([_MKH_CUDA_CXX14_TEST_PROGRAM],
  [AC_REQUIRE([_MKH_CUDA_BASIC_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_BASIC_TEST_MAIN])dnl
   AC_REQUIRE([_MKH_CUDA_CXX11_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_CXX11_TEST_MAIN])dnl
   AC_REQUIRE([_MKH_CUDA_CXX14_TEST_GLOBALS])dnl
   AC_REQUIRE([_MKH_CUDA_CXX14_TEST_MAIN])dnl
   m4_divert_once([INIT_PREPARE],
[[# C++14 CUDA test code (complete):
mkh_cuda_conftest_cxx14_program="$mkh_cuda_conftest_basic_globals
$mkh_cuda_conftest_cxx11_globals
$mkh_cuda_conftest_cxx14_globals
int main (int argc, char **argv)
{
  $mkh_cuda_conftest_basic_main
  $mkh_cuda_conftest_cxx11_main
  $mkh_cuda_conftest_cxx14_main
  return 0;
}
"
]])])

# _MKH_CUDA_CXX11_OPTIONS()
# -----------------------------------------------------------------------------
# Expands into a space-separated list of known flags needed to enable the
# support for the ISO C++ 2011 standard when running the CUDA C++ compiler.
#
m4_define([_MKH_CUDA_CXX11_OPTIONS], [-std=c++11])

# _MKH_CUDA_CXX14_OPTIONS()
# -----------------------------------------------------------------------------
# Expands into a space-separated list of known flags needed to enable the
# support for the ISO C++ 2014 standard when running the CUDA C++ compiler.
#
m4_define([_MKH_CUDA_CXX14_OPTIONS], [-std=c++14])
