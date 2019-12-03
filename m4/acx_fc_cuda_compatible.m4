# ACX_FC_CUDA_COMPATIBLE([ACTION-IF-SUCCESS],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether the Fortran compiler can link objects compiled with the CUDA
# compiler. First, tries to compile a simple CUDA code with the CUDA compiler
# and to link the resulting object into a Fortran program with the Fortran
# compiler.
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
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([ACX_PROG_NVCC])dnl
   AC_CACHE_CHECK(
     [whether Fortran compiler can link objects compiled with CUDA compiler],
     [acx_cv_fc_cuda_compatible],
     [AC_LANG_PUSH([CUDA])
      acx_cv_fc_cuda_compatible=no
      AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
#ifdef __cplusplus
extern "C"
{
#endif
void conftest_foo();
#ifdef __cplusplus
}
#endif
void conftest_foo(){}]])],
        [AC_LANG_POP([CUDA])
         mv ./conftest.$ac_objext ./conftest_cuda.$ac_objext
         acx_save_LIBS=$LIBS; LIBS="./conftest_cuda.$ac_objext $LIBS"
         AC_LINK_IFELSE([AC_LANG_SOURCE(
[[      program conftest
      implicit none
      interface
      subroutine conftest_foo() bind(c)
      end subroutine
      end interface
      call conftest_foo()
      end program]])],
           [acx_cv_fc_cuda_compatible=yes])
         LIBS=$acx_save_LIBS
         rm -f conftest_cuda.$ac_objext
         AC_LANG_PUSH([CUDA])])
      AC_LANG_POP([CUDA])])
   AS_VAR_IF([acx_cv_fc_cuda_compatible], [yes], [$1],
     [m4_default([$2],
        [AC_MSG_FAILURE([Fortran compiler cannot link objects compiled with dnl
CUDA compiler])])])])
