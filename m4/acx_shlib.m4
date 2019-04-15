# ACX_SHLIB_FC_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the Fortran compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the acx_cv_fc_rpath_flag variable.
#
AC_DEFUN([ACX_SHLIB_FC_RPATH_FLAG],
  [AC_REQUIRE([ACX_COMPILER_FC_VENDOR])_ACX_SHLIB_RPATH_FLAG])

# ACX_SHLIB_CC_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the acx_cv_c_rpath_flag variable.
#
AC_DEFUN([ACX_SHLIB_CC_RPATH_FLAG],
  [AC_REQUIRE([ACX_COMPILER_CC_VENDOR])_ACX_SHLIB_RPATH_FLAG])

# ACX_SHLIB_CXX_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the C++ compiler flag needed to add a directory to the
# runtime library search path.
#
# The result is cached in the acx_cv_cxx_rpath_flag variable.
#
AC_DEFUN([ACX_SHLIB_CXX_RPATH_FLAG],
  [AC_REQUIRE([ACX_COMPILER_CXX_VENDOR])_ACX_SHLIB_RPATH_FLAG])

# ACX_SHLIB_PATH_VAR()
# -----------------------------------------------------------------------------
# Sets the result to the name of the environment variable specifying the search
# paths for shared libraries.
#
# The result is cached in the acx_cv_shlib_path_var variable.
#
AC_DEFUN([ACX_SHLIB_PATH_VAR],
  [AC_REQUIRE([AC_CANONICAL_HOST])dnl
   AC_CACHE_CHECK([for the name of the environment variable specifying the dnl
search paths for shared libraries], [acx_cv_shlib_path_var],
     [AS_CASE([$host_os],
        [darwin*], [acx_cv_shlib_path_var=DYLD_LIBRARY_PATH],
        [acx_cv_shlib_path_var=LD_LIBRARY_PATH])])])

# _ACX_SHLIB_RPATH_FLAG()
# -----------------------------------------------------------------------------
# Sets the result to the compiler    flag needed to add a directory to the runtime
# library search path (requires calling _ACX_COMPILER_VENDOR first).
#
# The flag is cached in the acx_cv_[]_AC_LANG_ABBREV[]_rpath_flag variable.
#
m4_define([_ACX_SHLIB_RPATH_FLAG],
  [m4_pushdef([acx_cache_var], [acx_cv_[]_AC_LANG_ABBREV[]_rpath_flag])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler flag needed to add a directory to dnl
the runtime library search path], [acx_cache_var],
     [AS_CASE([AS_VAR_GET([acx_cv_[]_AC_LANG_ABBREV[]_compiler_vendor])],
        [nag], [acx_cache_var="-Wl,-Wl,,-rpath -Wl,-Wl,,"],
        [acx_cache_var="-Wl,-rpath -Wl,"])])
   m4_popdef([acx_cache_var])])
