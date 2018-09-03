# ACX_FC_CHECK_EXTRA_MOD_INC_PATHS(module-name, [path-to-check-for],
#   [ACTION-IF-FAILURE = FAILURE])
# ---------------------------------------------------------------------
# Check if an additional directory needs to be included in the list
# of module search paths to compile a program that requires
# module-name. If yes, check directories from the blank-separated list
# paths-to-check-for. If an additional directory is not required, the
# result is "none required". If the directory is required and is found,
# the result is the path to the directory. Otherwise, the result equals
# to "unknown" and ACTION-IF-FAILURE (defaults to failing with an error
# message) is run. The result is cached in the
# acx_cv_fc_[module-name]_extra_mod_inc_path variable.
AC_DEFUN([ACX_FC_CHECK_EXTRA_MOD_INC_PATHS],[
AC_REQUIRE([ACX_FC_MODULE_INC_FLAG])
AC_CACHE_CHECK([for extra include path to enable Fortran module $1],
[acx_cv_fc_$1_extra_mod_inc_path], [
AC_LANG_PUSH([Fortran])
acx_cv_fc_$1_extra_mod_inc_path=unknown
acx_fc_check_extra_mod_inc_paths_FCFLAGS_save=$FCFLAGS
for acx_fc_check_extra_mod_inc_paths_path in '' $2; do
  AS_IF([test -z "$acx_fc_check_extra_mod_inc_paths_path"],
    [acx_fc_check_extra_mod_inc_paths_on_success="none required"],
    [acx_fc_check_extra_mod_inc_paths_on_success=$acx_fc_check_extra_mod_inc_paths_path
    FCFLAGS="$acx_cv_fc_module_inc_flag$acx_fc_check_extra_mod_inc_paths_path $acx_fc_check_module_extra_inc_paths_FCFLAGS_save"])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[      use $1]])],
    [acx_cv_fc_$1_extra_mod_inc_path=$acx_fc_check_extra_mod_inc_paths_on_success
    break])
done
FCFLAGS=$acx_fc_check_extra_mod_inc_paths_FCFLAGS_save
AC_LANG_POP([Fortran])
])
AS_IF([test "x$acx_cv_fc_$1_extra_mod_inc_path" = xunknown],
  [m4_default([$3],
    [AC_MSG_ERROR([unable to find extra include directory to enable module $1])])])
AC_SUBST([FC_MODINC])
])
