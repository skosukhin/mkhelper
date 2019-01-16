# ACX_FC_C_MPI_COMPATIBLE([MPIRUN],
#                         [CONDITION = true])
# -----------------------------------------------------------------------------
# Checks whether Fortran and C MPI libraries are compatible. Tries to compile
# a C function that make calls to MPI functions. To make the result of the test
# more reliable, the resulting program can be run using the MPI launch command
# MPIRUN appended with two additional arguments: "-n 1" and the name of the
# linked executable. The run is performed only if the command CONDITION (
# defaults to true) finished with zero exitcode. The result is either "yes" or
# "no".
#
# The implementation implies that the Fortran compiler supports the BIND(C)
# attribute and can link object files compiled with the C compiler.
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
         AC_LINK_IFELSE([AC_LANG_SOURCE(
[[       program conftest
       implicit none
       interface
         subroutine conftestfoo() bind(c)
         end subroutine
       end interface
       call conftestfoo()
     end]])],
           [m4_ifval([$1],
              [m4_default([$2], [true])
               AS_IF([test $? -eq 0],
                 [AC_TRY_COMMAND(
                    [AS_VAR_GET([$1]) -n 1 ./conftest$ac_exeext dnl
>&AS_MESSAGE_LOG_FD])
                  AS_IF([test $? -eq 0],
                    [acx_cv_fc_c_mpi_compatible=yes])],
                 [acx_cv_fc_c_mpi_compatible=yes])],
              [acx_cv_fc_c_mpi_compatible=yes])])
         rm -f conftest_c.$ac_objext])])])