AC_INIT([mkhelper_picky], [1.0], [skosukhin@gmail.com])
AC_PREREQ([2.69])

AC_CONFIG_FILES([Makefile])

AC_PROG_CC

AS_IF([test -n "$FCFLAGS"],
  [AC_MSG_ERROR([FCFLAGS must always be empty])])

AC_ARG_ENABLE([silent-rules],
  [AS_HELP_STRING([--enable-silent-rules], [this option must never be set])],
     [AC_MSG_ERROR([this script must never receive an argument that would dnl
affect the option 'silent-rules'])])

AC_ARG_WITH([netcdf-root],
  [AS_HELP_STRING([--with-netcdf-root], [this option must never be set])],
     [AC_MSG_ERROR([this script must never receive an argument that would dnl
affect the option 'netcdf-root'])])

AC_ARG_ENABLE([always],
  [AS_HELP_STRING([--enable-always],
     [this option must always be enabled @<:@default: no@:>@])],
  [], [enable_always=no])

AS_IF([test x"$enable_always" != xyes],
  [AC_MSG_ERROR([this script must always receive an argument that would dnl
enable the option 'always'])])

AC_ARG_VAR([FCFLAGS], [this variable must be empty])

AC_OUTPUT
