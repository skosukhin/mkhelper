# ACX_CONFIG_SUBDIR(SUBDIR,
#                   [REMOVE-PATTERNS],
#                   [EXTRA-ARGS],
#                   [SHOW-RECURSIVE-HELP = no])
# -----------------------------------------------------------------------------
# Originally taken from Autoconf Archive where it is known as
# AX_SUBDIRS_CONFIGURE.
# -----------------------------------------------------------------------------
# Runs the configure script inside directory SUBDIR with the arguments of the
# parent script modified in the following way (in the designated order):
#     1) all arguments that match any of the shell case patterns listed in
#        the comma-separated list REMOVE-PATTERNS are removed; if the configure
#        script inside SUBDIR defines an option with either AC_ARG_ENABLE or
#        AC_ARG_WITH and you want to filter-out all arguments that might affect
#        this option, consider using ACX_CONFIG_SUBDIR_PATTERN_ENABLE and
#        ACX_CONFIG_SUBDIR_PATTERN_WITH, respectively.
#     2) all arguments from the comma-separated list EXTRA-ARGS are appended.
#
# This macro also sets the output variable subdirs_extra to the list of
# directories recorded with ACX_CONFIG_SUBDIR. This variable can be used in
# Makefile rules or substituted in configured files.
#
# If SHOW-RECURSIVE-HELP (defaults to no) is set to yes, the help message of the
# configure script in SUBDIR is shown together with the help message of the top
# level configure script when the latter is called with the argument
# '--help=recursive'. In that case, SUBDIR must be provided literally, without
# using shell variables.
#
# Consider calling AC_DISABLE_OPTION_CHECKING in you main configure.ac.
#
AC_DEFUN([ACX_CONFIG_SUBDIR],
  [m4_define([ACX_CONFIG_SUBDIR_FOR_$1])dnl
   m4_pushdef([acx_config_subdir_args], [_ACX_CONFIG_SUBDIR_ARG_VAR([$1])])dnl
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
   m4_popdef([acx_config_subdir_args])dnl
   _ACX_CONFIG_SUBDIR_APPEND_ARGS([$1], [$3])dnl
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
                   [_ACX_CONFIG_SUBDIR_ARG_VAR([$acx_config_subdir])])
                 AS_IF([test /dev/null != "$cache_file"],
                   [AS_CASE([$cache_file],
                      [[[\\/]]* | ?:[[\\/]]*],
                      [acx_sub_cache_file=$cache_file],
                      [acx_sub_cache_file="$ac_top_build_prefix$cache_file"])
                      acx_sub_cache_file=dnl
"$acx_sub_cache_file.`echo "$acx_config_subdir" | tr / .`"],
                   [acx_sub_cache_file=$cache_file])
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
            done
            AS_IF([test -n "$subdirs_extra"],
              [_AS_ECHO([===])
               _AS_ECHO_LOG([===])])])])])dnl
   m4_define([ACX_CONFIG_SUBDIR_COMMANDS_DEFINED])dnl
   m4_case(m4_default([$4], [no]),
     [yes],
     [AS_LITERAL_IF([$1],
        [m4_append([_AC_LIST_SUBDIRS], [$1], [
])],
        [m4_fatal([Invalid SHOW-RECURSIVE-HELP argument for $0: '$4' in ]dnl
[combination with a non-literal value for SUBDIR ('$1')])])],
     [no], [],
     [m4_fatal([Invalid SHOW-RECURSIVE-HELP argument for $0: '$4'])])])

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

# ACX_CONFIG_SUBDIR_APPEND_ARGS(SUBDIR,
#                               [EXTRA-ARGS])
# -----------------------------------------------------------------------------
# Appends arguments from the comma-separated list EXTRA-ARGS to the command
# that runs the configure script inside directory SUBDIR. Expansion of the
# macro must by expansion of ACX_CONFIG_SUBDIR with the same value for SUBDIR.
#
AC_DEFUN([ACX_CONFIG_SUBDIR_APPEND_ARGS],
  [AS_LITERAL_IF([$1],
     [m4_ifndef([ACX_CONFIG_SUBDIR_FOR_$1],
        [m4_fatal([$0($1) must be expanded after ACX_CONFIG_SUBDIR($1)])])],
     [m4_warn([syntax],
        [Undefined behaviour for $0: argument SUBDIR is given a ]dnl
[non-literal value: '$1'])])dnl
   _ACX_CONFIG_SUBDIR_APPEND_ARGS($@)])

# ACX_CONFIG_SUBDIR_VAR(VARIABLE,
#                       SUBDIR,
#                       TEMPLATE)
# -----------------------------------------------------------------------------
# Expands to a shell code setting the shell variable VARIABLE to the result of
# the variable substitution TEMPLATE done by the config.status script residing
# inside directory SUBDIR. The macro provides means of getting the results of
# the configure script from the subdirectory to the top-level configure script.
#
# For example, if 'subdir/configure' sets an output variable 'LIBM' and the
# value needs to be known in the top-level configure script, the way to do it
# is to expand the following:
#
# ACX_CONFIG_SUBDIR([subdir])
# AC_CONFIG_COMMANDS_PRE(
#   [ACX_CONFIG_SUBDIR_VAR([SUBDIR_VAR], [subdir], [@LIBM@])
#    AC_SUBST([SUBDIR_VAR])])
#
AC_DEFUN([ACX_CONFIG_SUBDIR_VAR],
  [acx_exec_result=`AS_ECHO([$3]) | "$2/config.status" -q --file=- 2>/dev/null`
   AS_IF([test $? -eq 0],
     [AS_VAR_COPY([$1], [acx_exec_result])],
     [AC_MSG_ERROR([unable to run '$2/config.status'])])])

# _ACX_CONFIG_SUBDIR_ARG_VAR(SUBDIR)
# -----------------------------------------------------------------------------
# Expands to the name of shell variable that holds arguments of the configure
# script inside directory SUBDIR.
#
m4_define([_ACX_CONFIG_SUBDIR_ARG_VAR],
  [acx_config_subdir_args_[]AS_TR_SH([$1])])

# _ACX_CONFIG_SUBDIR_APPEND_ARGS(SUBDIR,
#                                [EXTRA-ARGS])
# -----------------------------------------------------------------------------
# Implementation of the core logic that appends arguments from the
# comma-separated list EXTRA-ARGS to the command that runs the configure script
# inside directory SUBDIR.
#
m4_define([_ACX_CONFIG_SUBDIR_APPEND_ARGS],
  [m4_pushdef([acx_config_subdir_args], [_ACX_CONFIG_SUBDIR_ARG_VAR([$1])])dnl
   m4_ifnblank([$2],
     [set dummy m4_normalize(m4_foreach([opt], [$2], [opt ])) ; shift
      for acx_config_subdir_arg; do
        ASX_ESCAPE_SINGLE_QUOTE([acx_config_subdir_arg])
        AS_VAR_APPEND([acx_config_subdir_args], [" '$acx_config_subdir_arg'"])
      done])
   m4_popdef([acx_config_subdir_args])])
