# ACX_LANG_MPI_CHECK(MPIRUN,
#                    [TEST-SRC-DIR = $ac_aux_dir],
#                    [ACTION-IF-SUCCESS],
#                    [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Runs a series of tests of the MPI library by trying to compile and link
# programs in the current language. The successfully compiled programs are run
# with the MPI launcher command MPIRUN. Each file in the subdirectory
# TEST-SRC-DIR (defaults to the directory set with AC_CONFIG_AUX_DIR) of the
# source directory ($srcdir) with the extension of the current language
# (.$ac_ext) is treated separately. If the linking of a test fails, its result
# is "unknown", otherwise the result depends on the exit code of the command
# MPIRUN appended with two additional arguments: "-n acx_mpi_job_count" and the
# name of the linked executable. The value of acx_mpi_job_count can be set in
# the source file of the test program in the following format:
# acx_mpi_job_count=<positive integer>. The first substring in the source file
# that matches this format is taken into account, regardless whether it is
# commented or not. If such a substring is not found, acx_mpi_job_count is set
# to 1. If the command MPIRUN exits with zero exit status, the test is
# considered as passed and its result is "yes", otherwise the result is "no".
#
# Runs ACTION-IF-SUCCESS for each successful test and ACTION-IF-FAILURE
# (defaults to failing with an error message) for each failed (or "unknown")
# test. Both actions can get the path to the source file of the test program
# from the shell variable acx_prog_mpi_test_file and the result of the test
# from the shell variable acx_prog_mpi_test_result.
#
# The result if each test is cached in the
# acx_cv_prog_[]AS_TR_SH($acx_prog_mpi_test_file) variable.
#
AC_DEFUN([ACX_LANG_MPI_CHECK],
  [acx_save_[]_AC_LANG_PREFIX[]FLAGS=$[]_AC_LANG_PREFIX[]FLAGS
   for acx_prog_mpi_test_file in dnl
m4_ifval([$2], ["$srcdir/$4"], ["$ac_aux_dir"])/*.$ac_ext; do
     AS_VAR_PUSHDEF([acx_cache_var],
       [acx_cv_prog_${acx_prog_mpi_test_file}])dnl
     AC_CACHE_CHECK(
       [whether MPI implementation passes test "$acx_prog_mpi_test_file"],
       [acx_cache_var],
       [AS_VAR_SET([acx_cache_var], [unknown])
        acx_tmp=`sed -n '/acx_mpi_job_count *= *\([[0-9]]*\)/dnl
{s/.*acx_mpi_job_count *= *\([[0-9]]*\).*/\1/p
q}' "$acx_prog_mpi_test_file"`
        AS_IF([test "$acx_tmp" -gt 0 2>/dev/null], [], [acx_tmp=1])
        AC_LINK_IFELSE([AC_LANG_SOURCE([`cat "$acx_prog_mpi_test_file"`])],
          [AC_TRY_COMMAND(
             [AS_VAR_GET([$1]) -n $acx_tmp ./conftest$ac_exeext dnl
>&AS_MESSAGE_LOG_FD])
           AS_IF([test $? -eq 0],
             [AS_VAR_SET([acx_cache_var], [yes])],
             [AS_VAR_SET([acx_cache_var], [no])])])])
     AS_VAR_COPY([acx_prog_mpi_test_result], [acx_cache_var])
     AS_VAR_POPDEF([acx_cache_var])
     AS_VAR_IF([acx_prog_mpi_test_result], [yes], [$5], [m4_default([$6],
       [AC_MSG_FAILURE([MPI implementation failed test dnl
"$acx_prog_mpi_test_file"])])])
   done])