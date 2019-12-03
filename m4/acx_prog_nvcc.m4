# AC_LANG([CUDA])
# -----------------------------------------------------------------------------
# Define language CUDA with _AC_LANG_ABBREV set to "nvcc", _AC_LANG_PREFIX set
# to "NVC" (i.e. _AC_LANG_PREFIX[]FLAGS equals to 'NVCFLAGS'), _AC_CC set to
# "NVCC", and various language-specific Autoconf macros (e.g. AC_LANG_SOURCE)
# copied from C++ language.
#
# If you need to use AC_LANG([CUDA]), AC_LANG_PUSH([CUDA]), and
# AC_LANG_POP([CUDA]) in the "configure.ac", the following language definitions
# must be moved to the "acinclude.m4". Otherwise, you can use the wrappers
# ACX_LANG_CUDA, ACX_LANG_PUSH_CUDA, and ACX_LANG_POP_CUDA, respectively (see
# below).
#
AC_LANG_DEFINE([CUDA], [nvcc], [NVC], [NVCC], [C++],
[ac_ext=cu
ac_compile='$NVCC -c $NVCFLAGS conftest.$ac_ext >&AS_MESSAGE_LOG_FD'
ac_link='$NVCC -o conftest$ac_exeext $NVCFLAGS $LDFLAGS conftest.$ac_ext $LIBS >&AS_MESSAGE_LOG_FD'
ac_compiler_gnu=$acx_cv_nvcc_compiler_gnu
])
dnl Avoid mixing definitions that are relevant for C or C++ compiler and might
dnl be irrelevant for CUDA:
m4_copy_force([AC_LANG_CONFTEST()], [AC_LANG_CONFTEST(CUDA)])
AC_DEFUN([AC_LANG_COMPILER(CUDA)], [AC_REQUIRE([ACX_PROG_NVCC])])

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

# ACX_PROG_NVCC([LIST-OF-COMPILERS = nvcc])
# -----------------------------------------------------------------------------
# Searches for the NVIDIA CUDA Compiler command among the values of the
# blank-separated list LIST-OF-COMPILERS (defaults to a single value "nvcc").
# Declares precious variables NVCC and NVCFLAGS to be set to the compiler
# command and the compiler flags, respectively. If the environment variable
# NVCC is set, values of the list LIST-OF-COMPILERS are ignored.
#
# The macro also checks whether the compiler can actually compile CUDA code.
# The result is either "yes" or "no" and is cached in the acx_cv_prog_nvcc_cuda
# variable.
#
AC_DEFUN_ONCE([ACX_PROG_NVCC],
  [AC_LANG_PUSH([CUDA])dnl
   AC_ARG_VAR([NVCC], [NVIDIA CUDA Compiler command])dnl
   AC_ARG_VAR([NVCFLAGS], [NVIDIA CUDA Compiler flags])dnl
   _AC_ARG_VAR_LDFLAGS()dnl
   _AC_ARG_VAR_LIBS()dnl
   AS_IF([test -z "$NVCC"],
     [AC_CHECK_PROGS([NVCC], [m4_default([$1], [nvcc])])])
   _AS_ECHO_LOG([checking for CUDA compiler version])
   set dummy $ac_compile
   ac_compiler=$[2]
   _AC_DO_LIMIT([$ac_compiler --version >&AS_MESSAGE_LOG_FD])
   m4_expand_once([_AC_COMPILER_EXEEXT])[]dnl
   m4_expand_once([_AC_COMPILER_OBJEXT])[]dnl
   AC_CACHE_CHECK(
     [whether the host compiler of CUDA compiler supports GNU],
     [acx_cv_nvcc_compiler_gnu],
     [_AC_COMPILE_IFELSE(
        [AC_LANG_PROGRAM([], [[#ifndef __GNUC__
       choke me
#endif]])],
        [acx_cv_nvcc_compiler_gnu=yes],
        [acx_cv_nvcc_compiler_gnu=no])])
   AC_CACHE_CHECK([whether $NVCC can compile CUDA code],
     [acx_cv_prog_nvcc_cuda],
     [_AC_COMPILE_IFELSE(
        [AC_LANG_PROGRAM(
           [[__global__ void foo(float *x) { }]],
           [[float *x; cudaMalloc(&x, sizeof(float)); cudaFree(x);]])],
        [acx_cv_prog_nvcc_cuda=yes],
        [acx_cv_prog_nvcc_cuda=no])])
   AC_LANG_POP([CUDA])])

# ACX_PROG_NVCC_CXX11([ACTION-IF-SUCCESS = APPEND-NVCFLAGS],
#                     [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Finds the CUDA compiler flag needed to enable support for the C++11 dialect.
# The result is either "unsupported" or the actual compiler flag required to
# enable the dialect, which may be an empty string.
#
# If successful, runs ACTION-IF-SUCCESS (defaults to appending the result to
# NVCFLAGS), otherwise runs ACTION-IF-FAILURE (defaults to failing with an
# error message).
#
# The flag is cached in the acx_cv_prog_nvcc_cxx11.
#
AC_DEFUN([ACX_PROG_NVCC_CXX11],
  [AC_REQUIRE([ACX_PROG_NVCC])dnl
   AC_MSG_CHECKING([for $NVCC option to enable C++11 features])
   AC_CACHE_VAL([acx_cv_prog_nvcc_cxx11],
     [acx_cv_prog_nvcc_cxx11=unsupported
      AC_LANG_PUSH([CUDA])dnl
      AC_LANG_CONFTEST([AC_LANG_PROGRAM([[namespace test {
  template<typename T>
  class SomeClass {
  public:
    void operator() (T elem) {}
  };
}]],
        [[test::SomeClass<int> some_class = test::SomeClass<int>();
int* dev_nvalid = nullptr;]])])
      acx_save_NVCFLAGS=$NVCFLAGS
      for acx_flag in '' '-std=c++11'; do
        NVCFLAGS="$acx_save_NVCFLAGS $acx_flag"
        AC_COMPILE_IFELSE([], [acx_cv_prog_nvcc_cxx11=$acx_flag])
        test "x$acx_cv_prog_nvcc_cxx11" != xunsupported && break
      done
      NVCFLAGS=$acx_save_NVCFLAGS
      rm -f conftest.$ac_ext
      AC_LANG_POP([CUDA])])
   AS_IF([test -n "$acx_cv_prog_nvcc_cxx11"],
     [AC_MSG_RESULT([$acx_cv_prog_nvcc_cxx11])],
     [AC_MSG_RESULT([none needed])])
   AS_VAR_IF([acx_cv_prog_nvcc_cxx11], [unsupported],
     [m4_default([$2],
        [AC_MSG_FAILURE([unable to detect CUDA compiler flag needed to dnl
enable support for the C++11 dialect])])],
     [m4_default([$1],
        [AS_IF([test -n "$acx_cv_prog_nvcc_cxx11"],
           [AS_VAR_APPEND([NVCFLAGS], [" $acx_cv_prog_nvcc_cxx11"])])])])])
