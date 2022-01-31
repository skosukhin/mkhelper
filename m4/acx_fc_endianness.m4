# ACX_FC_ENDIANNESS_REAL([DOUBLE-PRECISION-KIND = KIND(1.d0)]
#                        [ACTION-IF-SUCCESS],
#                        [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Inspired by the AX_C_FLOAT_WORDS_BIGENDIAN macro in Autoconf Archive.
# -----------------------------------------------------------------------------
# Checks the floating-point endianness of the target system with the Fortran
# compiler. Tries to compile a program that sets a double-precision
# floating-point variable of type real and kind DOUBLE-PRECISION-KIND (defaults
# to KIND(1.d0)) to a value that can be interpreted as an ASCII string. The
# resulting object file is then grepped for several possible values, each
# representing the respective type of endianness:
#   - "mkhElper" - little-endian;
#   - "replEhkm" - big-endian;
#   - "lpermkhE" - half little-endian, half big-endian.
# The list above might be extended in the future to detect other types of
# mixed-endianness. If more than one string from the list matches the contents
# of the object, the result is "unknown".
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_fc_endianness_real variable.
#
AC_DEFUN([ACX_FC_ENDIANNESS_REAL],
  [AC_LANG_ASSERT([Fortran])dnl
   AC_MSG_CHECKING([for endianness of the target system])
   AC_CACHE_VAL([acx_cv_fc_endianness_real],
     [acx_cv_fc_endianness_real=unknown
      free_fmt='
      real(dp) :: b(2) = (/11436526043186408342932917319490312838905855&
      &2118841611962449784525241959417255606719874468829884522246508686&
      &0799336906947500199989578974774280030598291952243399484779227378&
      &5162269613202128034599963034475950452228997847642131801671155898&
      &01738240.0_dp,0.0_dp/)'
      fixed_fmt='
      real(dp) :: b(2) = (/11436526043186408342932917319490312838905855
     + 2118841611962449784525241959417255606719874468829884522246508686
     + 0799336906947500199989578974774280030598291952243399484779227378
     + 5162269613202128034599963034475950452228997847642131801671155898
     + 01738240.0_dp,0.0_dp/)'
     for acx_tmp in "$free_fmt" "$fixed_fmt"; do
       AC_COMPILE_IFELSE([AC_LANG_SOURCE([[      subroutine conftest(i, a)
      implicit none
      integer, parameter :: dp = ]m4_default([$1], [[KIND(1.d0)]])[
      integer :: i
      real(dp) :: a
$acx_tmp
      a = b(i)
      end subroutine]])],
         [for acx_tmp in mkhElper replEhkm lpermkhE; do
            AS_IF([grep "$acx_tmp" conftest.$ac_objext >/dev/null],
              [AS_VAR_IF([acx_cv_fc_endianness_real], [unknown],
                 [acx_cv_fc_endianness_real=$acx_tmp],
                 [acx_cv_fc_endianness_real=unknown
                  break])])
          done])
       test 0 -eq "$ac_retval" && break
     done
     ])
   acx_tmp=unknown
   AS_CASE([$acx_cv_fc_endianness_real],
     [mkhElper], [acx_tmp='little-endian'],
     [replEhkm], [acx_tmp='big-endian'],
     [lpermkhE], [acx_tmp='half little-endian, half big-endian'])
   AC_MSG_RESULT([$acx_tmp])
   AS_VAR_IF([acx_tmp], [unknown], [m4_default([$3], [AC_MSG_FAILURE(
     [unable to detect the endianness of the target system])])], [$2])])
