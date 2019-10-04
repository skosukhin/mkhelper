# ACX_COMPILER_CROSS_CHECK_DELAY()
# -----------------------------------------------------------------------------
# Delays the standard cross-compilation check to let the user avoid a false
# positive result (e.g. extend LDFLAGS with RPATHs, so the executable that is
# run during the check would not cause an error while loading shared libraries
# provided in LIBS).
#
# Example:
#     ACX_COMPILER_CROSS_CHECK_DELAY
#     AC_PROG_FC
#     AC_LANG([Fortran])
#     AC_FC_PP_SRCEXT([f90])
#     ACX_SHLIB_FC_RPATH_FLAG
#     LDFLAGS=`AS_ECHO(["$LDFLAGS"]) | dnl
#     sed ['s%\(-L[ ]*\([^ ][^ ]*\)\)%\1 '"$acx_cv_fc_rpath_flag"'\2%g']`
#     ACX_COMPILER_CROSS_CHECK_NOW
#
AC_DEFUN([ACX_COMPILER_CROSS_CHECK_DELAY],
  [acx_save_cross_compiling=$cross_compiling
   acx_save_ac_tool_warned=$ac_tool_warned
   cross_compiling=yes
   ac_tool_warned=yes
   m4_pushdef([_AC_COMPILER_EXEEXT_CROSS])])

# ACX_COMPILER_CROSS_CHECK_NOW()
# -----------------------------------------------------------------------------
# Runs the cross-compilation check that has been delayed with
# ACX_COMPILER_CROSS_CHECK_DELAY.
#
AC_DEFUN([ACX_COMPILER_CROSS_CHECK_NOW],
  [AC_PROVIDE_IFELSE([ACX_COMPILER_CROSS_CHECK_DELAY], [],
     [m4_fatal([$0 must be called after ACX_COMPILER_CROSS_CHECK_DELAY])])dnl
   cross_compiling=$acx_save_cross_compiling
   ac_tool_warned=$acx_save_ac_tool_warned
   m4_popdef([_AC_COMPILER_EXEEXT_CROSS])dnl
   AC_LANG_CONFTEST([_AC_LANG_IO_PROGRAM])
   _AC_COMPILER_EXEEXT_CROSS
   rm -f conftest.$ac_ext conftest$ac_exeext conftest.out])
