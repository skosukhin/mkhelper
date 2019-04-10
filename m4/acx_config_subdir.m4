# ACX_CONFIG_SUBDIR(SUBDIR,
#                   [REMOVE-PATTERNS],
#                   [EXTRA-ARGS])
# -----------------------------------------------------------------------------
# Originally taken from Autoconf Archive where it is known as
# AX_SUBDIRS_CONFIGURE.
# -----------------------------------------------------------------------------
# Runs the configure script inside directory SUBDIR with the arguments of the
# parent script modified in the following way (in that order):
#     1) all arguments that match any of the shell case patterns listed in
#        the comma-separated list REMOVE-PATTERNS are removed; if the configure
#        script inside SUBDIR defines an option with either AC_ARG_ENABLE or
#        AC_ARG_WITH and you want to filter-out all arguments that might affect
#        this option, consider using ACX_CONFIG_SUBDIR_PATTERN_ENABLE and
#        ACX_CONFIG_SUBDIR_PATTERN_WITH, respectively.
#     2) all arguments from the comma-separated list ARGS-TO-ADD are appended.
#
# This macro also sets the output variable subdirs_extra to the list of
# directories recorded with ACX_CONFIG_SUBDIR. This variable can be used in
# Makefile rules or substituted in configured files.
#
# Consider calling AC_DISABLE_OPTION_CHECKING in you main configure.ac.
#
AC_DEFUN([ACX_CONFIG_SUBDIR],
  [m4_pushdef([acx_config_subdir_args],
     [acx_config_subdir_args_[]AS_TR_SH([$1])])dnl
   AS_VAR_SET([acx_config_subdir_args])
   acx_config_subdir_ignore_arg=no
   eval "set dummy $ac_configure_args"; shift
   for acx_config_subdir_arg; do
     AS_VAR_IF([acx_config_subdir_ignore_arg], [no],
       [AS_CASE([$acx_config_subdir_arg],
          [-cache-file|--cache-file|--cache-fil|--cache-fi| \
           --cache-f|--cache-|--cache|--cach|--cac|--ca|--c| \
           -srcdir|--srcdir|--srcdi|--srcd|--src|--sr| \
           -prefix|--prefix|--prefi|--pref|--pre|--pr|--p],
          [acx_config_subdir_ignore_arg=yes],
          [-cache-file=*|--cache-file=*|--cache-fil=*|--cache-fi=*| \
           --cache-f=*|--cache-=*|--cache=*|--cach=*|--cac=*|--ca=*|--c=*| \
           --config-cache|-C| \
           -srcdir=*|--srcdir=*|--srcdi=*|--srcd=*|--src=*|--sr=*| \
           -prefix=*|--prefix=*|--prefi=*|--pref=*|--pre=*|--pr=*|--p=*| \
           --disable-option-checking], [],
           m4_foreach([opt], [$2], [m4_quote(opt), [],])
           [ASX_ESCAPE_SINGLE_QUOTE([acx_config_subdir_arg])
            AS_VAR_APPEND([acx_config_subdir_args],
              [" '$acx_config_subdir_arg'"])])],
       [acx_config_subdir_ignore_arg=no])
   done
   m4_ifnblank([$3],
     [set dummy m4_foreach([opt], [$3], [opt ]); shift
      for acx_config_subdir_arg; do
        ASX_ESCAPE_SINGLE_QUOTE([acx_config_subdir_arg])
        AS_VAR_APPEND([acx_config_subdir_args],
          [" '$acx_config_subdir_arg'"])
      done])
   m4_popdef([acx_config_subdir_args])dnl
   m4_ifdef([ACX_CONFIG_SUBDIR_COMMANDS_DEFINED],
     [AS_VAR_APPEND([subdirs_extra], [" $1"])],
     [AC_SUBST([subdirs_extra], ["$1"])
      AC_CONFIG_COMMANDS_PRE(
        [AS_VAR_IF([no_recursion], [yes],
           [subdirs_extra=],
           [acx_config_subdir_common_args="'--disable-option-checking'"
            AS_VAR_IF([silent], [yes],
              [AS_VAR_APPEND([acx_config_subdir_common_args],
                 [" '--silent'"])])
            acx_config_subdir_popdir=`pwd`
            for acx_config_subdir in $subdirs_extra; do
              acx_msg="=== configuring in $acx_config_subdir dnl
($acx_config_subdir_popdir/$acx_config_subdir)"
              _AS_ECHO_LOG([$acx_msg])
              _AS_ECHO([$acx_msg])
              AS_MKDIR_P(["$acx_config_subdir"])
              _AC_SRCDIRS(["$acx_config_subdir"])
              cd "$acx_config_subdir"
              AS_IF(
                [test -f "$ac_srcdir/configure.gnu"],
                [acx_config_subdir_script="$ac_srcdir/configure.gnu"],
                [test -f "$ac_srcdir/configure"],
                [acx_config_subdir_script="$ac_srcdir/configure"],
                [AC_MSG_ERROR(
                   [unable to configure '$acx_config_subdir': no configure dnl
script found])
                 acx_config_subdir_script=])
              AS_IF([test -n "$acx_config_subdir_script"],
                [AS_VAR_COPY([acx_config_subdir_args],
                   [acx_config_subdir_args_[]AS_TR_SH([$acx_config_subdir])])
                 AS_CASE([$cache_file],
                   [[[\\/]]* | ?:[[\\/]]*], [acx_sub_cache_file=$cache_file],
                   [acx_sub_cache_file="$ac_top_build_prefix$cache_file"])
                 for acx_config_subdir_arg in \
                   "--cache-file=$acx_sub_cache_file" \
                   "--srcdir=$ac_srcdir" \
                   "--prefix=$prefix"; do
                   ASX_ESCAPE_SINGLE_QUOTE([acx_config_subdir_arg])
                   AS_VAR_APPEND([acx_config_subdir_args],
                     [" '$acx_config_subdir_arg'"])
                 done
                 AS_VAR_APPEND([acx_config_subdir_args],
                   [" $acx_config_subdir_common_args"])
                 AC_MSG_NOTICE([running $SHELL $acx_config_subdir_script dnl
$acx_config_subdir_args])
                 eval "\$SHELL \"$acx_config_subdir_script\" dnl
$acx_config_subdir_args" || dnl
AC_MSG_ERROR([$acx_config_subdir_script failed for $acx_config_subdir])])
              cd "$acx_config_subdir_popdir"
            done])])])dnl
   m4_define([ACX_CONFIG_SUBDIR_COMMANDS_DEFINED])])

# ACX_CONFIG_SUBDIR_PATTERN_ENABLE(FEATURE)
# -----------------------------------------------------------------------------
# Expands to a shell case pattern that matches all valid arguments introduced
# with the standard Autoconf macro AC_ARG_ENABLE([PACKAGE]).
#
AC_DEFUN([ACX_CONFIG_SUBDIR_PATTERN_ENABLE],
  [[-enable-$1|-enable-$1=*|--enable-$1|--enable-$1=*|-disable-$1|]dnl
[--disable-$1]])

# ACX_CONFIG_SUBDIR_PATTERN_WITH(PACKAGE)
# -----------------------------------------------------------------------------
# Expands to a shell case pattern that matches all valid arguments introduced
# with the standard Autoconf macro AC_ARG_WITH([PACKAGE]).
#
AC_DEFUN([ACX_CONFIG_SUBDIR_PATTERN_WITH],
  [[-with-$1|-with-$1=*|--with-$1|--with-$1=*|-without-$1|--without-$1]])
