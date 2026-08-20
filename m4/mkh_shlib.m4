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

# MKH_SHLIB_FC_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the Fortran compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the mkh_cv_fc_rpath_flag variable.
#
AC_DEFUN([MKH_SHLIB_FC_RPATH_FLAG],
  [AC_REQUIRE([MKH_COMPILER_FC_VENDOR])_MKH_SHLIB_RPATH_FLAG])

# MKH_SHLIB_CC_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the mkh_cv_c_rpath_flag variable.
#
AC_DEFUN([MKH_SHLIB_CC_RPATH_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CC_VENDOR])_MKH_SHLIB_RPATH_FLAG])

# MKH_SHLIB_CXX_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C++ compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the mkh_cv_cxx_rpath_flag variable.
#
AC_DEFUN([MKH_SHLIB_CXX_RPATH_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CXX_VENDOR])_MKH_SHLIB_RPATH_FLAG])

# MKH_SHLIB_RPATH_FLAGS_CHECK([RPATH-FLAGS],
#                             [ACTION-IF-SUCCESS],
#                             [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Expands to a shell script that checks whether the current compiler accepts
# the automatically generated RPATH flags RPATH-FLAGS by trying to link a dummy
# program with LDFLAGS set to "RPATH-FLAGS $LDFLAGS".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
AC_DEFUN([MKH_SHLIB_RPATH_FLAGS_CHECK],
  [mkh_shlib_rpath_flags_check_result=no
   AC_MSG_CHECKING([whether _AC_LANG compiler accepts the automatically dnl
generated RPATH flags])
   m4_ifnblank([$1],
     [mkh_save_LDFLAGS=$LDFLAGS
      LDFLAGS="$1 $LDFLAGS"])
   AC_LINK_IFELSE([AC_LANG_PROGRAM],
     [mkh_shlib_rpath_flags_check_result=yes])
   m4_ifnblank([$1], [LDFLAGS=$mkh_save_LDFLAGS])
   AC_MSG_RESULT([$mkh_shlib_rpath_flags_check_result])
   AS_VAR_IF([mkh_shlib_rpath_flags_check_result], [yes], [$2],
     [m4_default([$3], [AC_MSG_FAILURE([_AC_LANG compiler does not accept dnl
the automatically generated RPATH flags[]m4_ifnblank([$1],[ '$1'])])])])])

# MKH_SHLIB_FC_PIC_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the Fortran compiler flag needed to generate the position
# independent code (PIC).
#
# The result is cached in the mkh_cv_fc_pic_flag variable.
#
AC_DEFUN([MKH_SHLIB_FC_PIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_FC_VENDOR])_MKH_SHLIB_PIC_FLAG])

# MKH_SHLIB_CC_PIC_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C compiler flag needed to generate the position
# independent code (PIC).
#
# The result is cached in the mkh_cv_c_pic_flag variable.
#
AC_DEFUN([MKH_SHLIB_CC_PIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CC_VENDOR])_MKH_SHLIB_PIC_FLAG([-DPIC])])

# MKH_SHLIB_CXX_PIC_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C++ compiler flag needed to generate the position
# independent code (PIC).
#
# The result is cached in the mkh_cv_cxx_pic_flag variable.
#
AC_DEFUN([MKH_SHLIB_CXX_PIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CXX_VENDOR])_MKH_SHLIB_PIC_FLAG([-DPIC])])

# MKH_SHLIB_PIC_FLAGS_CHECK([PIC-FLAGS],
#                           [ACTION-IF-SUCCESS],
#                           [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Expands to a shell script that checks whether the current compiler accepts
# the automatically generated PIC flags PIC-FLAGS by trying to link a dummy
# program with the compiler-specific flags appended with PIC-FLAGS.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
AC_DEFUN([MKH_SHLIB_PIC_FLAGS_CHECK],
  [mkh_shlib_pic_flags_check_result=no
   AC_MSG_CHECKING([whether _AC_LANG compiler accepts the automatically dnl
generated PIC flags])
   m4_ifnblank([$1],
     [mkh_save_[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
      AS_VAR_APPEND([_AC_LANG_PREFIX[]FLAGS], [" $1"])])
   AC_LINK_IFELSE([AC_LANG_PROGRAM],
     [mkh_shlib_pic_flags_check_result=yes])
   m4_ifnblank([$1],
     [_AC_LANG_PREFIX[]FLAGS=$mkh_save_[]_AC_LANG_PREFIX[]FLAGS])
   AC_MSG_RESULT([$mkh_shlib_pic_flags_check_result])
   AS_VAR_IF([mkh_shlib_pic_flags_check_result], [yes], [$2],
     [m4_default([$3], [AC_MSG_FAILURE([_AC_LANG compiler does not accept dnl
the automatically generated PIC flags[]m4_ifnblank([$1],[ '$1'])])])])])

# MKH_SHLIB_PATH_VAR()
# -----------------------------------------------------------------------------
# Sets the result to the name of the environment variable specifying the search
# paths for shared libraries.
#
# The result is cached in the mkh_cv_shlib_path_var variable.
#
AC_DEFUN([MKH_SHLIB_PATH_VAR],
  [AC_REQUIRE([AC_CANONICAL_HOST])dnl
   AC_CACHE_CHECK([for the name of the environment variable specifying the dnl
search paths for shared libraries], [mkh_cv_shlib_path_var],
     [AS_CASE([$host_os],
        [darwin*], [mkh_cv_shlib_path_var=DYLD_LIBRARY_PATH],
        [mkh_cv_shlib_path_var=LD_LIBRARY_PATH])])])

# MKH_SHLIB_PATH_VAR()
# -----------------------------------------------------------------------------
# Sets the result to the filename extension of shared libraries (without the
# leading dot).
#
# The result is cached in the mkh_cv_shlib_ext variable.
#
AC_DEFUN([MKH_SHLIB_EXT],
  [AC_REQUIRE([AC_CANONICAL_HOST])dnl
   AC_CACHE_CHECK([for the filename extension of shared libraries],
     [mkh_cv_shlib_ext],
     [AS_CASE([$host_os],
        [darwin*], [mkh_cv_shlib_ext=dylib],
        [mkh_cv_shlib_ext=so])])])

# MKH_SHLIB_FC_EXPORT_DYNAMIC_FLAG([ACTION-IF-SUCCESS],
#                                  [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Sets the result to the Fortran compiler flag needed to add all symbols to the
# dynamic symbol table.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_fc_export_dynamic_flag variable.
#
AC_DEFUN([MKH_SHLIB_FC_EXPORT_DYNAMIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_FC_VENDOR])_MKH_SHLIB_EXPORT_DYNAMIC_FLAG($@)])

# MKH_SHLIB_CC_EXPORT_DYNAMIC_FLAG([ACTION-IF-SUCCESS],
#                                  [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Sets the result to the C compiler flag needed to add all symbols to the
# dynamic symbol table.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_c_export_dynamic_flag variable.
#
AC_DEFUN([MKH_SHLIB_CC_EXPORT_DYNAMIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CC_VENDOR])_MKH_SHLIB_EXPORT_DYNAMIC_FLAG($@)])

# MKH_SHLIB_CXX_EXPORT_DYNAMIC_FLAG([ACTION-IF-SUCCESS],
#                                   [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Sets the result to the C++ compiler flag needed to add all symbols to the
# dynamic symbol table.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the mkh_cv_cxx_export_dynamic_flag variable.
#
AC_DEFUN([MKH_SHLIB_CXX_EXPORT_DYNAMIC_FLAG],
  [AC_REQUIRE([MKH_COMPILER_CXX_VENDOR])_MKH_SHLIB_EXPORT_DYNAMIC_FLAG($@)])

# _MKH_SHLIB_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the compiler flag needed to add a directory to the runtime
# library search path (requires calling _MKH_COMPILER_VENDOR first).
#
# The flag is cached in the mkh_cv_[]_AC_LANG_ABBREV[]_rpath_flag variable.
#
m4_define([_MKH_SHLIB_RPATH_FLAG],
  [m4_pushdef([mkh_cache_var], [mkh_cv_[]_AC_LANG_ABBREV[]_rpath_flag])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler flag needed to add a directory to dnl
the runtime library search path], [mkh_cache_var],
     [AS_CASE([AS_VAR_GET([mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
        [nag], [mkh_cache_var="-Wl,-Wl,,-rpath,,"],
        [mkh_cache_var="-Wl,-rpath,"])])
   m4_popdef([mkh_cache_var])])

# _MKH_SHLIB_PIC_FLAG([COMMON-EXTRA-FLAG])
# -----------------------------------------------------------------------------
# Sets the result to the compiler flag needed to generate the position
# independent code (PIC) (requires calling _MKH_COMPILER_VENDOR first). When
# provided, COMMON-EXTRA-FLAG is appended to the result.
#
# The flag is cached in the mkh_cv_[]_AC_LANG_ABBREV[]_pic_flag variable.
#
m4_define([_MKH_SHLIB_PIC_FLAG],
  [m4_pushdef([mkh_cache_var], [mkh_cv_[]_AC_LANG_ABBREV[]_pic_flag])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler flag needed to produce PIC],
     [mkh_cache_var],
     [AS_CASE([AS_VAR_GET([mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
        [nag], [mkh_cache_var='-PIC'],
        [portland], [mkh_cache_var='-fpic'],
        [sun], [mkh_cache_var='-KPIC'],
        [ibm], [mkh_cache_var='-qpic'],
        [mkh_cache_var='-fPIC'])
      m4_ifnblank([$1], [AS_VAR_APPEND([mkh_cache_var], [" $1"])])])
   m4_popdef([mkh_cache_var])])

# _MKH_SHLIB_EXPORT_DYNAMIC_FLAG([ACTION-IF-SUCCESS],
#                                [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Sets the result to the compiler flag needed to add all symbols to the dynamic
# symbol table (requires calling _MKH_COMPILER_VENDOR first).
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The flag is cached in the mkh_cv_[]_AC_LANG_ABBREV[]_export_dynamic_flag
# variable.
#
m4_define([_MKH_SHLIB_EXPORT_DYNAMIC_FLAG],
  [AC_REQUIRE([AC_CANONICAL_HOST])dnl
   m4_pushdef([mkh_cache_var],
     [mkh_cv_[]_AC_LANG_ABBREV[]_export_dynamic_flag])dnl
   AC_MSG_CHECKING([for _AC_LANG compiler flag needed to add all symbols to dnl
the dynamic symbol table])
   AC_CACHE_VAL([mkh_cache_var],
     [mkh_cache_var=unknown
      AS_CASE([$host_os],
        [darwin*], [mkh_cache_var=],
        [AS_CASE([AS_VAR_GET([mkh_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
           [nag], [mkh_cache_var='-Wl,-Wl,,--export-dynamic'],
           [mkh_cache_var='-Wl,--export-dynamic'])])
      AS_IF([test -n "$mkh_cache_var" && test "x$mkh_cache_var" != xunknown],
        [mkh_save_LDFLAGS=$LDFLAGS
         LDFLAGS="$mkh_cache_var $LDFLAGS"
         AC_LINK_IFELSE([AC_LANG_PROGRAM], [], [mkh_cache_var=unknown])
         LDFLAGS=$mkh_save_LDFLAGS])])
   AS_IF([test -n "$mkh_cache_var"],
     [AC_MSG_RESULT([$mkh_cache_var])],
     [AC_MSG_RESULT([none needed])])
   AS_VAR_IF([mkh_cache_var], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect _AC_LANG compiler flag needed to dnl
add all symbols to the dynamic symbol table])])], [$1])
   m4_popdef([mkh_cache_var])])
