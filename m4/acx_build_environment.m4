# ACX_BUILD_ENVIRONMENT()
# -----------------------------------------------------------------------------
# Declares a precious variable BUILD_ENV to be set to the initialization code
# of the building environment. If the variable is not empty (i.e. set by the
# user), tests whether the code is accepted by the $SHELL. If the test is
# successful, tries to run the code to initialize the shell of the configure
# script for the following checks. If either the test or the attempt to run the
# contents of BUILD_ENV inside the configure script fail, the expanded script
# fails the configuration.
#
AC_DEFUN([ACX_BUILD_ENVIRONMENT],
  [AC_ARG_VAR([BUILD_ENV],
     [initialization code to set up the building environment (must end ]dnl
[with a semicolon), e.g. 'LICENSE=file.lic; export LICENSE;'])dnl
   AS_IF([test -n "$BUILD_ENV"],
     [AS_IF([AS_ECHO(["$BUILD_ENV"]) | grep ';@<:@ @:>@*$' >/dev/null 2>&1],
        [],
        [AC_MSG_ERROR(
           [\$BUILD_ENV does not end with a semicolon: '$BUILD_ENV'])])
      AC_MSG_CHECKING([whether \$BUILD_ENV is accepted by '$SHELL -c'])
      acx_BUILD_ENV=$BUILD_ENV
      ASX_ESCAPE_SINGLE_QUOTE([acx_BUILD_ENV])
      _AS_ECHO_LOG([$SHELL -c '$acx_BUILD_ENV'])
      eval \$SHELL -c "'$acx_BUILD_ENV'" >&AS_MESSAGE_LOG_FD 2>&1
      AS_IF([test $? -eq 0],
        [AC_MSG_RESULT([yes])
         AC_MSG_CHECKING(
           [whether \$BUILD_ENV is accepted by the current shell])
         _AS_ECHO_LOG([$BUILD_ENV])
         eval "$BUILD_ENV" >&AS_MESSAGE_LOG_FD 2>&1
         AS_IF([test $? -eq 0],
           [AC_MSG_RESULT([yes])
            AC_CONFIG_COMMANDS_PRE(
              [BUILD_ENV=`echo "$BUILD_ENV" | sed 's/\\$/$$/g'`])],
           [AC_MSG_RESULT([no])])],
        [AC_MSG_RESULT([no])
         acx_failMsg="failed to initialize '$SHELL' with the provided dnl
BUILD_ENV='$BUILD_ENV'
A possible workaround for the problem is to re-run the configuration with dnl
the following command:
CONFIG_SHELL=\$SHELL \$SHELL $as_myself"
         for acx_config_arg in "$[@]"; do
           AS_VAR_APPEND([acx_failMsg], " '$acx_config_arg'")
         done
         AC_MSG_FAILURE([$acx_failMsg])])])])
