# ACX_HOST_FQDN([ACTION-IF-SUCCESS],
#               [ACTION-IF-FAILURE = FAILURE])
# -----------------------------------------------------------------------------
# Detects the fully qualified domain name (FQDN) of the host. The result is
# either "unknown" or a string with the fully qualified domain name.
#
# If successful, runs ACTION-IF-SUCCESS, otherwise runs ACTION-IF-FAILURE
# (defaults to failing with an error message).
#
# The result is cached in the acx_cv_host_fqdn variable.
#
AC_DEFUN([ACX_HOST_FQDN],
  [AC_CACHE_CHECK([for the fully qualified domain name of the host],
     [acx_cv_host_fqdn],
     [dnl The easiest way to get the result:
      acx_cv_host_fqdn=`hostname -f 2>/dev/null`
      AS_IF([test $? -ne 0 || test -z "$acx_cv_host_fqdn"],
        [acx_cv_host_fqdn=unknown
dnl If the previous attempt didn't work, try to find the hostname first:
dnl   use the 'hostname' and 'uname -n' commands:
         acx_hostname=`(hostname || uname -n) 2>/dev/null | sed 1q`
dnl   or use the value of the HOSTNAME environment variable:
         test -n "$acx_hostname" || acx_hostname=$HOSTNAME
dnl   or read '/proc/sys/kernel/hostname' (not portable):
         test -n "$acx_hostname" || acx_hostname=`cat /proc/sys/kernel/hostname 2>/dev/null`
dnl   Try to call to the 'host' command if the hostname is detected:
         test -n "$acx_hostname" && dnl
acx_cv_host_fqdn=`host "$acx_hostname" 2>/dev/null | dnl
awk '/has address/ {print $[1]}' 2>/dev/null`])
dnl Set the result to unknown if it is empty:
      test -n "$acx_cv_host_fqdn" || acx_cv_host_fqdn=unknown])
   AS_VAR_IF([acx_cv_host_fqdn], [unknown], [m4_default([$2],
     [AC_MSG_FAILURE([unable to detect the fully qualified domain name of dnl
the host])])], [$1])])
