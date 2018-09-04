# ACX_CHECK_PROGS(variable-name, progs-to-check-for, check-message,
# ACTION-TO-CHECK, value-if-not-found)
# ---------------------------------------------------------------------
# Check for each program in the blank-separated list progs-to-check-for
# and run ACTION-TO-CHECK with it (action must result in non-zero exit
# status on failure, the candidate program can be referenced as
# $acx_prog_candidate) and set variable-name to the value of the first
# program that passed the check successfully. If variable-name is
# already set, run the check with its value and ignore
# progs-to-check-for. Set variable-name to value-if-not-found if all
# checks failed. The result is cached to the acx_cv_prog_variable_name
# variable.
AC_DEFUN([ACX_CHECK_PROGS],
[AC_CACHE_CHECK([$3], [acx_cv_prog_$1],
[AS_IF([test -n "$$1"], [set dummy "$$1"], [set dummy $2])
shift
acx_cv_prog_$1=$5
for acx_prog_candidate in "$[@]"; do
$4
AS_IF([test $? -eq 0], [acx_cv_prog_$1="$acx_prog_candidate"; break])
done])
$1=$acx_cv_prog_$1
])
