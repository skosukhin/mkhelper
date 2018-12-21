# $1 - package, $2 - include flag, $3 - link flag
#               $4 - default include suffix $5 - default lib suffix
#
AC_DEFUN([ACX_PACKAGE_INIT_ARGS],
  [AS_VAR_PUSHDEF([acx_pkg_ROOT], [AS_TR_CPP([$1])[_ROOT]])dnl
   AC_ARG_WITH([ASX_TR_ARG($1)-root],
     [AS_HELP_STRING([--with-]ASX_TR_ARG($1)[-root=]acx_pkg_ROOT,
        [root search path for $1 headers and libraries])])dnl
   AS_VAR_PUSHDEF([acx_pkg_with_root],
     [with_[]AS_TR_SH(ASX_TR_ARG($1))[]_root])dnl

   m4_ifval([$2],
     [AS_VAR_PUSHDEF([acx_pkg_INCLUDE],
        [AS_TR_CPP([$1])[_]_AC_LANG_PREFIX[_INCLUDE]])dnl
      AC_ARG_VAR(acx_pkg_INCLUDE, [specific flags enabling $1 headers])dnl
      AS_VAR_SET_IF([acx_pkg_INCLUDE],
        [acx_pkg_INCLUDE[]_was_given=yes],
        [acx_pkg_INCLUDE[]_was_given=no])
      AC_ARG_WITH([ASX_TR_ARG($1)-include],
        [AS_HELP_STRING([--with-]ASX_TR_ARG($1)[-include]=DIR,
           [search path for $1 headers @<:@]acx_pkg_ROOT[/]dnl
m4_default([$4],[include])[@:>@])],
        [AS_IF([test x"$[]acx_pkg_INCLUDE[]_was_given" = "xno"],
           [AS_VAR_SET([acx_pkg_INCLUDE], ["$2[]${withval}"])])],
        [AS_IF([test x"$[]acx_pkg_INCLUDE[]_was_given" = "xno"],
           [AS_VAR_SET_IF([acx_pkg_with_root],
              [AS_VAR_SET([acx_pkg_INCLUDE],
                 ["$2${[]acx_pkg_with_root[]}/m4_default([$4],[include])[]"]dnl
               )])])])dnl
      AS_VAR_POPDEF([acx_pkg_INCLUDE])])dnl

   m4_ifval([$3],
     [AS_VAR_PUSHDEF([acx_pkg_LIB],
        [AS_TR_CPP([$1])[_]_AC_LANG_PREFIX[_LIB]])dnl
      AC_ARG_VAR(acx_pkg_LIB, [specific flags enabling $1 libraries])dnl
      AS_VAR_SET_IF([acx_pkg_LIB],
        [acx_pkg_LIB[]_was_given=yes],
        [acx_pkg_LIB[]_was_given=no])
      AC_ARG_WITH([ASX_TR_ARG($1)-lib],
        [AS_HELP_STRING([--with-]ASX_TR_ARG($1)[-lib]=DIR,
           [search path for $1 libraries @<:@]acx_pkg_ROOT[/]dnl
m4_default([$5],[lib])[@:>@])],
        [AS_IF([test x"$[]acx_pkg_LIB[]_was_given" = "xno"],
           [AS_VAR_SET([acx_pkg_LIB], ["$3[]${withval}"])])],
        [AS_IF([test x"$[]acx_pkg_LIB[]_was_given" = "xno"],
           [AS_VAR_SET_IF([acx_pkg_with_root],
              [AS_VAR_SET([acx_pkg_LIB],
                 ["$3${[]acx_pkg_with_root[]}/[]m4_default([$5],[lib])[]"]dnl
               )])])])dnl
      AS_VAR_POPDEF([acx_pkg_LIB])])dnl
   AS_VAR_POPDEF([acx_pkg_ROOT])dnl
   AS_VAR_POPDEF([acx_pkg_with_root])])

AC_DEFUN([ASX_TR_ARG],
  [AS_LITERAL_IF([$1],
     [m4_translit(AS_TR_SH([$1]), [_A-Z], [-a-z])],
     [m4_bpatsubst(AS_TR_SH([$1]), [`$],
        [ | tr '_[]m4_cr_LETTERS[]' '-[]m4_cr_letters[]'`])])])
