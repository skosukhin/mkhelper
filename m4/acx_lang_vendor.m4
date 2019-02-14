# ACX_LANG_VENDOR([ACTION-IF-SUCCESS],
#                 [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Originally taken from Autoconf Archive where it is known as
# AX_COMPILER_VENDOR.
# -----------------------------------------------------------------------------
# Detects the vendor of the compiler based on its intrinsic preprocessor
# macros. The result is "unknown" or one of the vendor IDs (see
# _ACX_LANG_KNOWN_VENDORS).
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_[]_AC_LANG_ABBREV[]_vendor variable.
#
AC_DEFUN([ACX_LANG_VENDOR],
  [m4_pushdef([acx_cache_var], [acx_cv_[]_AC_LANG_ABBREV[]_vendor])dnl
   AC_CACHE_CHECK([for _AC_LANG compiler vendor], [acx_cache_var],
     [acx_lang_vendor_options="m4_foreach([pair], [_ACX_LANG_KNOWN_VENDORS],
        [m4_n(m4_car(pair): m4_shift(pair))])unknown: UNKNOWN"
      for acx_lang_vendor_test in $acx_lang_vendor_options; do
        AS_CASE([$acx_lang_vendor_test],
          [*:], [acx_lang_vendor_candidate=$acx_lang_vendor_test
                 continue],
          [acx_lang_vendor_macro_defs="defined("`echo $acx_lang_vendor_test dnl
| sed 's%,%) || defined(%g'`")"])
        AC_COMPILE_IFELSE(
          [AC_LANG_PROGRAM([],
[[#if !($acx_lang_vendor_macro_defs)
      choke me
#endif]])],
          [break])
      done
      acx_cache_var=`echo $acx_lang_vendor_candidate | cut -d: -f1`])
   AS_VAR_IF([acx_cache_var], [unknown], [m4_default([$2],
        [AC_MSG_FAILURE([unable to detect _AC_LANG compiler vendor])])], [$1])
   m4_popdef([acx_cache_var])])

# _ACX_LANG_KNOWN_VENDORS()
# -----------------------------------------------------------------------------
# Expands into a language-specific comma-separated list of pairs. The first
# value in each pair is the compiler vendor ID, the second value is a
# comma-separated list of the vendor-specific intrinsic preprocessor macros.
# By default, expands to m4_fatal with the message saying that _AC_LANG is not
# supported.
#
m4_define([_ACX_LANG_KNOWN_VENDORS],
  [m4_ifdef([$0(]_AC_LANG[)],
     [m4_indir([$0(]_AC_LANG[)], $@)],
     [m4_fatal([the list of ]_AC_LANG[ compiler vendors is undefined])])])

# _ACX_LANG_KNOWN_VENDORS(C)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_KNOWN_VENDORS for C language.
#
m4_define([_ACX_LANG_KNOWN_VENDORS(C)],
  [[intel, [__ICC,__ECC,__INTEL_COMPILER]],
   [cray, [_CRAYC]],
   [pgi, [__PGI]],
   [ibm, [__xlc__,__xlC__,__IBMC__,__IBMCPP__]],
   [pathscale, [__PATHCC__,__PATHSCALE__]],
   [clang, [__clang__]],
   [fujitsu, [__FUJITSU]],
   [sdcc, [SDCC,__SDCC]],
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
   [tcc, [__TINYC__]]])

# _ACX_LANG_KNOWN_VENDORS(Fortran)()
# -----------------------------------------------------------------------------
# Implementation of _ACX_LANG_KNOWN_VENDORS for Fortran language. Additionally
# checks that the flag enabling preprocessing of the Fortran source files is
# already set.
#
m4_define([_ACX_LANG_KNOWN_VENDORS(Fortran)],
  [AC_PROVIDE_IFELSE([AC_FC_PP_SRCEXT], [],
     [m4_warn([syntax],
        [ACX_LANG_VENDOR requires calling the Fortran compiler with a ]dnl
[preprocessor but no call to AC_FC_PP_SRCEXT is detected])])dnl
[intel, [__INTEL_COMPILER]],
[cray, [_CRAYFTN]],
[pgi, [__PGI]],
[nag, [NAGFOR]],
[sun, [__SUNPRO_F95]],
[gnu, [__GFORTRAN__]],
[ibm, [__xlC__]]])
