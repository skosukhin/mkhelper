# ACX_PROG_SEARCH(VARIABLE,
#                 [CANDIDATES],
#                 [CHECK-SCRIPT = 'eval $acx_candidate'],
#                 [ACTION-IF-SUCCESS],
#                 [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Searches for the program (command) that results into a zero exit status of
# the CHECK-SCRIPT (defaults to running the candidate command). CHECK-SCRIPT
# can get the tested command from the shell variable $acx_candidate. If the
# shell variable VARIABLE is set, checks whether the value it stores passes the
# test. If VARIABLE is not set, iterates over the values of the blank-separated
# list CANDIDATES and stops when the first valid command is found. The value of
# VARIABLE is never set or changed.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# A positive result of this test is cached in the
# acx_cv_prog_[]AS_TR_SH(VARIABLE) variable.
#
AC_DEFUN([ACX_PROG_SEARCH],
  [AS_VAR_PUSHDEF([acx_cache_var], [acx_cv_prog_$1])dnl
   AS_LITERAL_IF([$1],
     [AC_MSG_CHECKING([for m4_tolower([$1])])],
     [acx_tmp=`AS_ECHO(["$1"]) | tr 'm4_cr_LETTERS' 'm4_cr_letters'`
      AC_MSG_CHECKING([for $acx_tmp])])
   AS_VAR_SET_IF([acx_cache_var],
     [AS_ECHO_N(["(cached) "]) >&AS_MESSAGE_FD],
     [AS_VAR_SET_IF([$1], [set dummy "AS_VAR_GET([$1])"], [set dummy $2])
      shift
      for acx_candidate in "$[@]"; do
        m4_default([$3],
          [AC_TRY_COMMAND([$acx_candidate >&AS_MESSAGE_LOG_FD])])
        AS_IF([test $? -eq 0],
          [AS_VAR_SET([acx_cache_var], [$acx_candidate])
           break])
      done])
   AS_VAR_SET_IF([acx_cache_var],
     [AC_MSG_RESULT([AS_VAR_GET(acx_cache_var)])
      $4],
     [AC_MSG_RESULT([unknown])
      m4_default([$5],
        [AS_LITERAL_IF([$1],
           [AC_MSG_FAILURE([unable to find m4_tolower([$1])])],
           [acx_tmp=`AS_ECHO(["$1"]) | tr 'm4_cr_LETTERS' 'm4_cr_letters'`
            AC_MSG_FAILURE([unable to find $acx_tmp])])])])
   AS_VAR_POPDEF([acx_cache_var])])

# ACX_PROG_SEARCH_PATH(PROG-TO-CHECK-FOR,
#                      [ACTION-IF-SUCCESS],
#                      [ACTION-IF-FAILURE = FAILURE],
#                      [PATH = $PATH])
# -----------------------------------------------------------------------------
# Originally taken from the master branch of Autoconf where it is known as
# _AC_PATH_PROG.
# -----------------------------------------------------------------------------
# Searches for the path to the PROG-TO-CHECK-FOR program in the list of
# directories stored in the PATH (defaults to the value of the $PATH shell
# variable) as a list separated with the value of the $PATH_SEPARATOR shell
# variable, which is set by the configure script during the initialization (the
# usual value is ':'). The result is either "unknown" or PROG-TO-CHECK-FOR
# prepended with the path to the first word in PROG-TO-CHECK-FOR.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is stored in the acx_prog_search_path shell variable.
#
AC_DEFUN([ACX_PROG_SEARCH_PATH],
  [acx_prog_search_path=unknown
   set dummy $1; acx_tmp=$[2]
   AC_MSG_CHECKING([for the path to $acx_tmp])
   AS_CASE(["$acx_tmp"],
     [[[\\/]]* | ?:[[\\/]]*],
     [AS_IF([AS_EXECUTABLE_P(["$acx_tmp"])],
        [acx_prog_search_path="$1"
         AC_MSG_RESULT([$acx_tmp])])],
     [_AS_PATH_WALK([$4],
        [AS_IF([AS_EXECUTABLE_P(["$as_dir/$acx_tmp"])],
           [acx_prog_search_path="$as_dir/$1"
            AC_MSG_RESULT([$as_dir/$acx_tmp])
            break])])])
   AS_VAR_IF([acx_prog_search_path], [unknown],
     [AC_MSG_RESULT([unknown])
      m4_default([$3],
        [AC_MSG_FAILURE([unable to find the path to $acx_tmp])])],
     [$2])])
