# Copyright (c) 2018-2025, MPI-M
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

# ACX_LANG_CUDA_COMPATIBLE([ACTION-IF-SUCCESS],
#                          [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the compiler for the current language can link objects
# compiled with the CUDA compiler. Tries to compile a simple CUDA code with the
# CUDA compiler and link the resulting object into a program in the current
# language with the corresponding compiler.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_[]_AC_LANG_ABBREV[]_cuda_compatible
# variable.
#
AC_DEFUN([ACX_LANG_CUDA_COMPATIBLE],
  [m4_pushdef([acx_cache_var], [acx_cv_[]_AC_LANG_ABBREV[]_cuda_compatible])dnl
   AC_CACHE_CHECK(
     [whether _AC_LANG compiler can link objects compiled with CUDA compiler],
     [acx_cache_var],
     [_ACX_LANG_CUDA_COMPATIBLE([[
extern "C" void conftest_cuda_foo() {
  // Call functions that require CUDA runtime library:
  float* x;
  cudaError_t err = cudaMalloc(&x, sizeof(float));
  err = cudaFree(x);
}]])
      acx_cache_var=$acx_lang_cuda_compatible])
   AS_VAR_IF([acx_cache_var], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([_AC_LANG compiler cannot link objects compiled dnl
with CUDA compiler])])])
   m4_popdef([acx_cache_var])])

# ACX_LANG_CUDA_COMPATIBLE_STDCXX([ACTION-IF-SUCCESS],
#                                 [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the compiler for the current language can link objects
# compiled with the CUDA compiler from sources that require C++ standard
# library. Tries to compile a simple C++ code with the CUDA compiler and link
# the resulting object into into a program in the current language with the
# corresponding compiler.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_[]_AC_LANG_ABBREV[]_cuda_compatible_stdcxx
# variable.
#
AC_DEFUN([ACX_LANG_CUDA_COMPATIBLE_STDCXX],
  [m4_pushdef([acx_cache_var],
     [acx_cv_[]_AC_LANG_ABBREV[]_cuda_compatible_stdcxx])dnl
   AC_CACHE_CHECK(
     [whether _AC_LANG compiler can link objects compiled with CUDA dnl
compiler that require C++ standard library],
     [acx_cache_var],
     [_ACX_LANG_CUDA_COMPATIBLE([[
/* An attempt to write a function that would keep the dependency on the
   standard C++ library even with a high optimization level, i.e. -O3 */
#include <vector>
std::vector<int>* a;
extern "C" void conftest_cuda_foo() {
  a->push_back(1);
}]])
      acx_cache_var=$acx_lang_cuda_compatible])
   AS_VAR_IF([acx_cache_var], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([_AC_LANG compiler cannot link objects compiled dnl
with CUDA compiler that require C++ standard library])])])
   m4_popdef([acx_cache_var])])

# _ACX_LANG_CUDA_COMPATIBLE(FOO-CUDA-CODE,
#                           [EXTRA-ACTIONS])
# -----------------------------------------------------------------------------
# Checks whether the compiler for the current language can link a program that
# makes a call to a CUDA C function "void conftest_cuda_foo()". First, tries to
# compile FOO-CUDA-CODE with the CUDA compiler and link the resulting object
# into a program in the current language with the corresponding compiler. The
# result is either "yes" or "no". If you need to run extra commands upon
# successful linking (e.g. you need to run the result of the linking, i.e.
# "./conftest$ac_exeext"), you can put them as the EXTRA-ACTIONS argument. In
# that case, the result of the macro will be "yes" only if the exit code of the
# last command listed in EXTRA-ACTIONS is zero.
#
# The result is stored in the acx_lang_cuda_compatible variable.
#
m4_define([_ACX_LANG_CUDA_COMPATIBLE],
  [AC_REQUIRE([ACX_PROG_CUDACXX])dnl
   AC_LANG_PUSH([CUDA])
   acx_lang_cuda_compatible=no
   AC_COMPILE_IFELSE([AC_LANG_SOURCE([$1])],
     [AC_LANG_POP([CUDA])
      AC_TRY_COMMAND([mv ./conftest.$ac_objext ./conftest_cuda.$ac_objext])
      acx_save_LIBS=$LIBS; LIBS="./conftest_cuda.$ac_objext $LIBS"
      AC_LINK_IFELSE(
        [AC_LANG_SOURCE([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM])],
        [m4_ifval([$2],
           [$2
            AS_IF([test $? -eq 0], [acx_lang_cuda_compatible=yes])],
           [acx_lang_cuda_compatible=yes])])
      LIBS=$acx_save_LIBS
      rm -f conftest_cuda.$ac_objext
      AC_LANG_PUSH([CUDA])])
   AC_LANG_POP([CUDA])])

# _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM()
# -----------------------------------------------------------------------------
# Expands into the source code of a program in the current language that calls
# a C function "void conftest_cuda_foo()". By default, expands to m4_fatal with
# the message saying that _AC_LANG is not supported.
#
m4_define([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM],
  [m4_ifdef([$0(]_AC_LANG[)],
     [m4_indir([$0(]_AC_LANG[)], $@)],
     [m4_fatal([the CUDA call program is not defined for ]dnl
_AC_LANG[ language])])])

# _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM for C language.
#
m4_define([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C)],
  [dnl
dnl We do not use AC_LANG_CALL here because we want a zero exit status upon
dnl successful run of the program.
   AC_LANG_PROGRAM([[
#ifdef __cplusplus
extern "C"
#endif
void conftest_cuda_foo();]],
[[conftest_cuda_foo()]])])

# _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C++)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM for C++ language.
#
m4_copy([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C)],
  [_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C++)])

# _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(CUDA)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM for CUDA language.
#
m4_copy([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(C)],
  [_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(CUDA)])

# _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(Fortran)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM for Fortran language
# (implies that the Fortran compiler supports the BIND(C) attribute).
#
m4_define([_ACX_LANG_CUDA_COMPATIBLE_CALL_PROGRAM(Fortran)],
  [AC_LANG_PROGRAM([],
[[      implicit none
      interface
      subroutine conftest_cuda_foo() bind(c)
      end subroutine
      end interface
      call conftest_cuda_foo()]])])
