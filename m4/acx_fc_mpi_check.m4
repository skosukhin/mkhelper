# ACX_FC_MPI_CHECK([ACTION-IF-TRUE], [ACTION-IF-FALSE = FAILURE])
# ----------------------------------------------------------------------------
# Checks if Fortran compiler support MPI.
AC_DEFUN([ACX_FC_MPI_CHECK],[
AC_CACHE_CHECK([whether Fortran 90 can link a simple MPI program], [acx_cv_prog_fc_mpi],
[AC_LANG_PUSH([Fortran])
AC_LINK_IFELSE([AC_LANG_CALL([],[MPI_INIT])],
  [ acx_cv_prog_fc_mpi=yes ],
  [ acx_cv_prog_fc_mpi=no ])
AC_LANG_POP([Fortran])
])
AS_IF([test x"$acx_cv_prog_fc_mpi" = xyes],
  [$1],
  [m4_default(
    [$2],
    [AC_MSG_ERROR([Fortran 90 cannot link a simple MPI program])])])
])

