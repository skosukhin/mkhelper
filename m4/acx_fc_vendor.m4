# ACX_FC_VENDOR()
# ---------------------------------------------------------------------
# The idea is taken from the AX_COMPILER_VENDOR, which can be found at
# https://www.gnu.org/software/autoconf-archive/ax_compiler_vendor.html
# ---------------------------------------------------------------------
# Detect the vendor of the Fortran compiler. The result
# is either "unknown" or one of the following:
# gnu, intel, pgi, sun, cray, nag
#
# The result is cached in the acx_cv_fc_vendor variable.
AC_DEFUN([ACX_FC_VENDOR],[
AC_REQUIRE([AC_PROG_FC])
AC_CACHE_CHECK([for Fortran compiler vendor], [acx_cv_fc_vendor], [
_acx_fc_vendor_options="intel: __INTEL_COMPILER
                        cray: _CRAYFTN
                        pgi: __PGI
                        nag: NAGFOR
                        sun: __SUNPRO_F90,__SUNPRO_F95
                        gnu: __GNUC__,__GFORTRAN__
                        unknown: UNKNOWN"
for _acx_fc_vendor_test in $_acx_fc_vendor_options; do
  AS_CASE([$_acx_fc_vendor_test],
          [*:], [_acx_fc_vendor_candidate=$_acx_fc_vendor_test; continue],
          [_acx_fc_vendor_defs="defined("`echo $_acx_fc_vendor_test | sed 's/,/) || defined(/g'`")"])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [[
#if !($_acx_fc_vendor_defs)
      choke me
#endif]])], [break])
done
acx_cv_fc_vendor=`echo $_acx_fc_vendor_candidate | cut -d: -f1`
])])
