# ACX_FC_C_MPI_COMPATIBLE([MPIRUN = true],
#                         [ACTION-IF-SUCCESS],
#                         [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Checks whether Fortran and C MPI libraries are compatible. Tries to compile
# a C function that make calls to MPI functions. To make the result of the test
# more reliable, the resulting program is run using the MPI launch command
# MPIRUN (defaults to "true", which unconditionally exits with a zero exit
# status) appended with two additional arguments: "-n 1" and the name of the
# linked executable. The result is either "yes" or "no".
#
# The implementation implies that the Fortran compiler supports the BIND(C)
# attribute and can link object files compiled with the C compiler.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_c_mpi_compatible variable.
#
AC_DEFUN([ACX_FC_C_MPI_COMPATIBLE],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_REQUIRE([AC_PROG_CC])dnl
   AC_CACHE_CHECK([whether C and Fortran MPI libraries are compatible],
     [acx_cv_fc_c_mpi_compatible],
     [acx_cv_fc_c_mpi_compatible=no
      AC_LANG_PUSH([C])
      AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
#include <mpi.h>
void conftestfoo()
{ int world_size, world_rank, name_len;
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  MPI_Init(0, 0);
  MPI_Comm_size(MPI_COMM_WORLD, &world_size);
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
  MPI_Get_processor_name(processor_name, &name_len);
  MPI_Finalize(); }]])],
        [AC_LANG_POP([C])
         mv ./conftest.$ac_objext ./conftest_c.$ac_objext
         acx_save_LIBS=$LIBS; LIBS="./conftest_c.$ac_objext $LIBS"
         AC_LINK_IFELSE([AC_LANG_SOURCE(
[[       program conftest
       implicit none
       interface
         subroutine conftestfoo() bind(c)
         end subroutine
       end interface
       call conftestfoo()
     end]])],
           [AC_TRY_COMMAND(
              [m4_default([$1], [true]) -n 1 ./conftest$ac_exeext dnl
>&AS_MESSAGE_LOG_FD])
            AS_IF([test $? -eq 0], [acx_cv_fc_c_mpi_compatible=yes])])
         LIBS=$acx_save_LIBS
         rm -f conftest_c.$ac_objext])])
   AS_VAR_IF([acx_cv_fc_c_mpi_compatible], [yes], [$2],
     [m4_default([$3],
        [AC_MSG_FAILURE([FC and C MPI libraries are not compatible])])])])