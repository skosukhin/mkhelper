# ACX_FC_CUDA_COMPATIBLE([ACTION-IF-SUCCESS],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler can link objects compiled with the CUDA
# compiler. Tries to compile a simple CUDA code with the CUDA compiler and to
# link the resulting object into a Fortran program with the Fortran compiler.
#
# The implementation implies that the Fortran compiler supports the BIND(C)
# attribute.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_cuda_compatible variable.
#
AC_DEFUN([ACX_FC_CUDA_COMPATIBLE],
  [AC_CACHE_CHECK(
     [whether Fortran compiler can link objects compiled with CUDA compiler],
     [acx_cv_fc_cuda_compatible],
     [_ACX_FC_CUDA_COMPATIBLE([[
#ifdef __cplusplus
extern "C"
{
#endif
void conftest_foo();
#ifdef __cplusplus
}
#endif
void conftest_foo(){}]])
      acx_cv_fc_cuda_compatible=$acx_fc_cuda_compatiable])
   AS_VAR_IF([acx_cv_fc_cuda_compatible], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([Fortran compiler cannot link objects compiled with dnl
CUDA compiler])])])])

# ACX_FC_CUDA_STDCXX_COMPATIBLE([ACTION-IF-SUCCESS],
#                               [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler can link objects compiled with the CUDA
# compiler from sources that require C++ standard library. Tries to compile a
# simple C++ code with the CUDA compiler and to link the resulting object into a
# Fortran program with the Fortran compiler.
#
# The implementation implies that the Fortran compiler supports the BIND(C)
# attribute.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_cuda_stdcxx_compatible variable.
#
AC_DEFUN([ACX_FC_CUDA_STDCXX_COMPATIBLE],
  [AC_CACHE_CHECK(
     [whether Fortran compiler can link objects compiled with CUDA compiler dnl
that require C++ standard library],
     [acx_cv_fc_cuda_stdcxx_compatible],
     [_ACX_FC_CUDA_COMPATIBLE([[
#include <vector>
#ifdef __cplusplus
extern "C"
{
#endif
void conftest_foo();
#ifdef __cplusplus
}
#endif

/* An attempt to write a function that would keep the dependency on the
   standard C++ library even with a high optimization level, i.e. -O3 */
volatile void* p;
void conftest_foo() {
  std::vector<int> b = *(std::vector<int>*)p;
  b.push_back(1);
}]])
      acx_cv_fc_cuda_stdcxx_compatible=$acx_fc_cuda_compatiable])
   AS_VAR_IF([acx_cv_fc_cuda_stdcxx_compatible], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([Fortran compiler cannot link objects compiled with dnl
CUDA compiler that require C++ standard library])])])])

# _ACX_FC_CUDA_COMPATIBLE(FOO-CUDA-CODE,
#                         [EXTRA-ACTIONS])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler can link a program that makes a call to
# a parameterless CUDA function "conftest_foo", which returns void, using the
# ISO_C_BINDING module. First, tries to compile FOO-C-CODE with the CUDA
# compiler and to link the resulting object into a Fortran program with the
# Fortran compiler. The result is either "yes" or "no". If you need to run extra
# commands upon successful linking (e.g. you need to run the result of the
# linking, i.e. "./conftest$ac_exeext"), you can put them as EXTRA-ACTIONS
# argument. In that case the result of the macro will be "yes" only if the exit
# code of the last command listed in EXTRA-ACTIONS is zero.
#
# The result is stored in the acx_fc_cuda_compatiable variable.
#
m4_define([_ACX_FC_CUDA_COMPATIBLE],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([ACX_PROG_NVCC])dnl
   AC_LANG_PUSH([CUDA])
   acx_fc_cuda_compatiable=no
   AC_COMPILE_IFELSE([AC_LANG_SOURCE([$1])],
     [AC_LANG_POP([CUDA])
      mv ./conftest.$ac_objext ./conftest_cuda.$ac_objext
      acx_save_LIBS=$LIBS; LIBS="./conftest_cuda.$ac_objext $LIBS"
      AC_LINK_IFELSE(
        [AC_LANG_SOURCE(
[[      program conftest
      implicit none
      interface
      subroutine conftest_foo() bind(c)
      end subroutine
      end interface
      call conftest_foo()
      end program]])],
        [m4_ifval([$2],
           [$2
            AS_IF([test $? -eq 0], [acx_fc_cuda_compatiable=yes])],
           [acx_fc_cuda_compatiable=yes])])
      LIBS=$acx_save_LIBS
      rm -f conftest_cuda.$ac_objext
      AC_LANG_PUSH([CUDA])])
   AC_LANG_POP([CUDA])])
