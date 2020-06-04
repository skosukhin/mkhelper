AC_INIT([threaded_hello], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([threaded_hello_f.f90])

AM_INIT_AUTOMAKE([1.16.1 foreign])
AM_MAINTAINER_MODE([enable])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

LT_PREREQ([2.4.6])
LT_INIT([pic-only])
dnl Clean up after Libtool checks for C compiler:
rm -f a.out

AX_PTHREAD(
  [LIBS="$PTHREAD_LIBS $LIBS"
   CFLAGS="$CFLAGS $PTHREAD_CFLAGS"
   CC="$PTHREAD_CC"],
  [AC_MSG_FAILURE([unable to detect flags needed to enable POSIX Threads])])

AC_PROG_FC
dnl Clean up after Libtool checks for Fortran compiler:
rm -f a.out

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
