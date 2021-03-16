# AC_LANG([CUDA])
# -----------------------------------------------------------------------------
# Define language CUDA with _AC_LANG_ABBREV set to "cuda", _AC_LANG_PREFIX set
# to "CUDA" (i.e. _AC_LANG_PREFIX[]FLAGS equals to 'CUDAFLAGS'), _AC_CC set to
# "CUDAC", and various language-specific Autoconf macros (e.g. AC_LANG_SOURCE)
# copied from C++ language.
#
# If you want to use AC_LANG([CUDA]), AC_LANG_PUSH([CUDA]), and
# AC_LANG_POP([CUDA]) in the "configure.ac", you need to include this file
# explicitly, e.g. "m4_include([m4/acx_cuda.m4])". Another option is two copy
# the following language definitions to the "acinclude.m4". Otherwise, you can
# use the wrappers ACX_LANG_CUDA, ACX_LANG_PUSH_CUDA, and ACX_LANG_POP_CUDA,
# respectively (see below).
#
AC_LANG_DEFINE([CUDA], [cuda], [CUDA], [CUDAC], [C++],
[ac_ext=cu
ac_compile='$CUDAC -c $CUDAFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_link='$CUDAC -o conftest$ac_exeext $CUDAFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&AS_MESSAGE_LOG_FD'
ac_compiler_gnu=$acx_cv_cuda_compiler_gnu
])
dnl Avoid mixing macro definitions that are relevant for C or C++ compiler and
dnl might be irrelevant for CUDA:
m4_copy_force([AC_LANG_CONFTEST()], [AC_LANG_CONFTEST(CUDA)])
dnl Redefine the null program. It is supposed to do nothing but is used in the
dnl initial checks of the compiler. To avoid false positive results of those
dnl checks, we define a program that a regular C compiler does not handle.
m4_define([_AC_LANG_NULL_PROGRAM(CUDA)],
[AC_LANG_PROGRAM(
   [__global__ void foo(float *x) { }],
   [float *x; cudaMalloc(&x, sizeof(float)); cudaFree(x)])])
AC_DEFUN([AC_LANG_COMPILER(CUDA)], [AC_REQUIRE([ACX_PROG_CUDAC])])

# ACX_LANG_CUDA()
# ACX_LANG_PUSH_CUDA()
# ACX_LANG_POP_CUDA()
# -----------------------------------------------------------------------------
# A set of macro wrapping AC_LANG([CUDA]), AC_LANG_PUSH([CUDA]), and
# AC_LANG_POP([CUDA]), respectively, that can be used in the "configure.ac"
# to switch to/from CUDA language without the need to move the language
# definition (see above) to the "acinclude.m4" file.
#
AC_DEFUN([ACX_LANG_CUDA], [AC_LANG([CUDA])])
AC_DEFUN([ACX_LANG_PUSH_CUDA], [AC_LANG_PUSH([CUDA])])
AC_DEFUN([ACX_LANG_POP_CUDA], [AC_LANG_POP([CUDA])])

# ACX_PROG_CUDAC([LIST-OF-COMPILERS = nvcc])
# -----------------------------------------------------------------------------
# Searches for the CUDA Compiler command among the values of the
# blank-separated list LIST-OF-COMPILERS (defaults to a single value "nvcc").
# Declares precious variables CUDAC and CUDAFLAGS to be set to the compiler
# command and the compiler flags, respectively. If the environment variable
# CUDAC is set, values of the list LIST-OF-COMPILERS are ignored.
#
AC_DEFUN_ONCE([ACX_PROG_CUDAC],
  [AC_LANG_PUSH([CUDA])dnl
   AC_ARG_VAR([CUDAC], [CUDA Compiler command])dnl
   AC_ARG_VAR([CUDAFLAGS], [CUDA Compiler flags])dnl
   _AC_ARG_VAR_LDFLAGS()dnl
   _AC_ARG_VAR_LIBS()dnl
   AS_IF([test -z "$CUDAC"],
     [AC_CHECK_PROGS([CUDAC], [m4_default([$1], [nvcc])])])
   _AS_ECHO_LOG([checking for CUDA compiler version])
   set dummy $ac_compile
   ac_compiler=$[2]
   _AC_DO_LIMIT([$ac_compiler --version >&AS_MESSAGE_LOG_FD])
   m4_expand_once([_AC_COMPILER_EXEEXT])[]dnl
   m4_expand_once([_AC_COMPILER_OBJEXT])[]dnl
   _AC_LANG_COMPILER_GNU
   AC_LANG_POP([CUDA])])