# If you need to add support for a new vendor, add it to the language-specific
# version of the list _ACX_COMPILER_KNOWN_VENDORS. If the vendor sets
# additional preprocessor macros, put them in the list too, otherwise, you will
# have to implement additional detection algorithm (see the case of NAG in
# ACX_COMPILER_CC_VENDOR).
#
# If these macros look like an overkill to you, consider using
# ACX_COMPILER_*_VENDOR_SIMPLE macros.

# ACX_COMPILER_FC_VENDOR()
# -----------------------------------------------------------------------------
# Detects the vendor of the Fortran compiler. The result is "unknown" or one of
# the vendor IDs (see _ACX_COMPILER_KNOWN_VENDORS(Fortran)).
#
# The result is cached in the acx_cv_fc_compiler_vendor variable.
#
AC_DEFUN([ACX_COMPILER_FC_VENDOR],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_PROVIDE_IFELSE([AC_FC_PP_SRCEXT], [],
     [m4_warn([syntax],
        [ACX_COMPILER_FC_VENDOR requires calling the Fortran compiler with ]dnl
[a preprocessor but no call to AC_FC_PP_SRCEXT is detected])])dnl
   AC_CACHE_CHECK([for Fortran compiler vendor], [acx_cv_fc_compiler_vendor],
     [AS_IF(
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^AMD clang version' >/dev/null 2>&1],
        [acx_cv_fc_compiler_vendor=amd],
        [_ACX_COMPILER_VENDOR])])])

# ACX_COMPILER_CC_VENDOR()
# -----------------------------------------------------------------------------
# Detects the vendor of the C compiler. The result is "unknown" or one of
# the vendor IDs (see _ACX_COMPILER_KNOWN_VENDORS(C)).
#
# The result is cached in the acx_cv_c_compiler_vendor variable.
#
AC_DEFUN([ACX_COMPILER_CC_VENDOR],
  [AC_LANG_ASSERT([C])dnl
   AC_CACHE_CHECK([for C compiler vendor], [acx_cv_c_compiler_vendor],
     [AS_IF(
        [AS_VAR_GET([_AC_CC]) -V 2>&1 | dnl
grep '^NAG Fortran Compiler Release' >/dev/null 2>&1],
        [acx_cv_c_compiler_vendor=nag],
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^AMD clang version' >/dev/null 2>&1],
        [acx_cv_c_compiler_vendor=amd],
        [_ACX_COMPILER_VENDOR])])])

# ACX_COMPILER_CXX_VENDOR()
# -----------------------------------------------------------------------------
# Detects the vendor of the C++ compiler. The result is "unknown" or one of
# the vendor IDs (see _ACX_COMPILER_KNOWN_VENDORS(C)).
#
# The result is cached in the acx_cv_cxx_compiler_vendor variable.
#
AC_DEFUN([ACX_COMPILER_CXX_VENDOR],
  [AC_LANG_ASSERT([C++])dnl
   AC_CACHE_CHECK([for C++ compiler vendor], [acx_cv_cxx_compiler_vendor],
     [AS_IF(
        [AS_VAR_GET([_AC_CC]) --version 2>&1 | dnl
grep '^AMD clang version' >/dev/null 2>&1],
        [acx_cv_cxx_compiler_vendor=amd],
        [_ACX_COMPILER_VENDOR])])])

# _ACX_COMPILER_KNOWN_VENDORS()
# -----------------------------------------------------------------------------
# Expands into a language-specific m4-quoted comma-separated list of pairs. The
# first value in each pair is the compiler vendor ID, the second value is a
# comma-separated list of the vendor-specific intrinsic preprocessor macros.
# By default, expands to m4_fatal with the message saying that _AC_LANG is not
# supported.
#
m4_define([_ACX_COMPILER_KNOWN_VENDORS],
  [m4_ifdef([$0(]_AC_LANG[)],
     [m4_indir([$0(]_AC_LANG[)], $@)],
     [m4_fatal([the list of ]_AC_LANG[ compiler vendors is undefined])])])

# _ACX_COMPILER_KNOWN_VENDORS(Fortran)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_COMPILER_KNOWN_VENDORS for Fortran language.
#
m4_define([_ACX_COMPILER_KNOWN_VENDORS(Fortran)],
[[[intel, [__INTEL_COMPILER,__INTEL_LLVM_COMPILER]],
  [cray, [_CRAYFTN]],
  [nec, [__NEC__]],
  [portland, [__PGI]],
  [nag, [NAGFOR]],
  [sun, [__SUNPRO_F95]],
  [gnu, [__GFORTRAN__]],
  [ibm, [__xlC__]],
  [amd],
  [flang, [__FLANG,__flang__]]]])

# _ACX_COMPILER_KNOWN_VENDORS(C)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_COMPILER_KNOWN_VENDORS for C language.
#
m4_define([_ACX_COMPILER_KNOWN_VENDORS(C)],
[[[intel, [__ICC,__ECC,__INTEL_COMPILER,__INTEL_LLVM_COMPILER]],
  [cray, [_CRAYC,__cray__]],
  [nec, [__NEC__]],
  [portland, [__PGI,__NVCOMPILER]],
  [amd],
  [ibm, [__xlc__,__xlC__,__IBMC__,__IBMCPP__]],
  [pathscale, [__PATHCC__,__PATHSCALE__]],
  [apple, [__apple_build_version__]],
  [clang, [__clang__]],
  [fujitsu, [__FUJITSU]],
  [sdcc, [SDCC,__SDCC]],
  [nag],
  [gnu, [__GNUC__]],
  [sun, [__SUNPRO_C,__SUNPRO_CC]],
  [hp, [__HP_cc,__HP_aCC]],
  [dec, [__DECC,__DECCXX,__DECC_VER,__DECCXX_VER]],
  [borland, [__BORLANDC__,__CODEGEARC__,__TURBOC__]],
  [comeau, [__COMO__]],
  [kai, [__KCC]],
  [lcc, [__LCC__]],
  [sgi, [__sgi,sgi]],
  [microsoft, [_MSC_VER]],
  [metrowerks, [__MWERKS__]],
  [watcom, [__WATCOMC__]],
  [tcc, [__TINYC__]]]])

# _ACX_COMPILER_KNOWN_VENDORS(C++)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_COMPILER_KNOWN_VENDORS for C++ language.
#
m4_copy([_ACX_COMPILER_KNOWN_VENDORS(C)], [_ACX_COMPILER_KNOWN_VENDORS(C++)])

# _ACX_COMPILER_VENDOR()
# -----------------------------------------------------------------------------
# Originally taken from Autoconf Archive where it is known as
# AX_COMPILER_VENDOR.
# -----------------------------------------------------------------------------
# Detects the vendor of the compiler based on its intrinsic preprocessor
# macro. The result is "unknown" or one of the vendor IDs
# (see _ACX_COMPILER_KNOWN_VENDORS).
#
# The result is stored in the acx_cv_[]_AC_LANG_ABBREV[]_compiler_vendor
# variable.
#
m4_define([_ACX_COMPILER_VENDOR],
  [acx_compiler_vendor_options=dnl
"m4_foreach([pair], _ACX_COMPILER_KNOWN_VENDORS,
    [m4_ifnblank(m4_quote(m4_shift(pair)), m4_n(m4_car(pair): m4_cdr(pair)))])dnl
unknown: CHOKEME"
      acx_success=no
      for acx_compiler_vendor_test in $acx_compiler_vendor_options; do
        AS_CASE([$acx_compiler_vendor_test],
          [*:], [acx_compiler_vendor_candidate=$acx_compiler_vendor_test
                 continue],
          [acx_compiler_vendor_macro_defs=dnl
"defined("`echo $acx_compiler_vendor_test | sed 's%,%) || defined(%g'`")"])
        AC_COMPILE_IFELSE(
          [AC_LANG_PROGRAM([],
[[#if !($acx_compiler_vendor_macro_defs)
      choke me
#endif]])],
          [acx_success=yes])
        test "x$acx_success" = xyes && break
      done
      AS_VAR_SET([acx_cv_[]_AC_LANG_ABBREV[]_compiler_vendor],
        [`echo $acx_compiler_vendor_candidate | cut -d: -f1`])])
