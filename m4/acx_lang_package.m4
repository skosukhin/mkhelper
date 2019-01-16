# ACX_LANG_PACKAGE_INIT(PACKAGE-NAME,
#                       [INC-SEARCH-FLAGS],
#                       [LIB-SEARCH-FLAGS],
#                       [INC-SEARCH-SUFFIX = /include],
#                       [LIB-SEARCH-SUFFIX = /lib])
# -----------------------------------------------------------------------------
# Sets command-line arguments of the configure script that allow users to set
# search paths for the PACKAGE-NAME. By default, sets only the
# "--with-package-name-root" argument.
#
# If the argument INC-SEARCH-FLAGS is not blank, adds a command-line argument
# "--with-package-name-include", declares a precious variable
# AS_TR_CPP(PACKAGE-NAME)_AC_LANG_PREFIX[]FLAGS (e.g. PACKAGE_NAME_FCFLAGS),
# and sets a shell variable
# acx_[]_AC_LANG_ABBREV[]_[]AS_TR_SH(PACKAGE-NAME)_inc_search_args
# (e.g. acx_fc_Package_Name_inc_search_args). The latter variable is set to
# a string containing each flag from the space-separated list INC-SEARCH-FLAGS
# appended either with the value of the command-line argument
# "--with-package-name-include" (if given) or with the concatenation of the
# value of the command-line argument "--with-package-name-root" (if given) and
# INC-SEARCH-SUFFIX (defaults to /include). If neither of the two mentioned
# command-line arguments is given the variable
# acx_[]_AC_LANG_ABBREV[]_[]AS_TR_SH(PACKAGE-NAME)_inc_search_args is empty.
#
# If the argument LIB-SEARCH-FLAGS is given, adds a command-line argument
# "--with-package-name-lib", declares a precious variable
# AS_TR_CPP(PACKAGE-NAME)_AC_LANG_PREFIX[]LIBS (e.g. PACKAGE_NAME_FCLIBS), and
# sets a shell variable
# acx_[]_AC_LANG_ABBREV[]_[]AS_TR_SH(PACKAGE-NAME)_lib_search_args (e.g.
# acx_fc_Package_Name_lib_search_args). The value for the latter variable is
# set according to the same rules as for the variable related to the include
# search path (LIB-SEARCH-SUFFIX defaults to /lib).
#
AC_DEFUN([ACX_LANG_PACKAGE_INIT],
  [m4_pushdef([acx_package_ROOT], [AS_TR_CPP([$1]_ROOT)])dnl
   m4_pushdef([acx_package_with_root],
     [with_[]AS_TR_SH([ASX_TR_ARG([$1])])_root])dnl
   AC_ARG_WITH(ASX_TR_ARG([$1])[-root],
     [AC_HELP_STRING([--with-ASX_TR_ARG([$1])-root=[]acx_package_ROOT],
        [root search path for $1 headers and libraries])])
   m4_ifnblank([$2],
     [m4_pushdef([acx_package_with_include],
        [with_[]AS_TR_SH([ASX_TR_ARG([$1])])_include])dnl
      AC_ARG_WITH(ASX_TR_ARG([$1])[-include],
        [AC_HELP_STRING([--with-ASX_TR_ARG([$1])-include=DIR],
           [search path for $1 headers @<:@]acx_package_ROOT[]dnl
m4_default([$4], [/include])[@:>@])], [],
           [AS_VAR_SET_IF([acx_package_with_root],
              [acx_package_with_include="${acx_package_with_root}dnl
m4_default([$4], [/include])"])])
      AC_ARG_VAR(AS_TR_CPP([$1])_[]_AC_LANG_PREFIX[FLAGS],
        [exact ]_AC_LANG[ compiler flags enabling $1])
      AS_VAR_SET_IF([acx_package_with_include],
        [for acx_flag in $2; do
           ASX_VAR_APPEND_UNIQ(
             [acx_[]_AC_LANG_ABBREV[]_[]AS_TR_SH([$1])_inc_search_args],
             ["${acx_flag}${acx_package_with_include}"], [" "])
         done])
      m4_popdef([acx_package_with_include])])
   m4_ifnblank([$3],
     [m4_pushdef([acx_package_with_lib],
        [with_[]AS_TR_SH([ASX_TR_ARG([$1])])_lib])dnl
      AC_ARG_WITH(ASX_TR_ARG([$1])[-lib],
        [AC_HELP_STRING([--with-ASX_TR_ARG([$1])-lib=DIR],
           [search path for $1 libraries @<:@]acx_package_ROOT[]dnl
m4_default([$5], [/lib])[@:>@])],
           [],
           [AS_VAR_SET_IF([acx_package_with_root],
              [acx_package_with_lib="${acx_package_with_root}dnl
m4_default([$5], [/lib])"])])
      AC_ARG_VAR(AS_TR_CPP([$1])_[]_AC_LANG_PREFIX[LIBS],
        [exact linker flags enabling $1 when linking with ]_AC_LANG[ compiler])
      AS_VAR_SET_IF([acx_package_with_lib],
        [for acx_flag in $3; do
           ASX_VAR_APPEND_UNIQ(
             [acx_[]_AC_LANG_ABBREV[]_[]AS_TR_SH([$1])_lib_search_args],
             ["${acx_flag}${acx_package_with_lib}"], [" "])
         done])
      m4_popdef([acx_package_with_lib])])
   m4_popdef([acx_package_ROOT])dnl
   m4_popdef([acx_package_with_root])])

# ASX_TR_ARG(EXPRESSION)
# -----------------------------------------------------------------------------
# Transforms EXPRESSION into shell code that generates a name for a command
# line argument. The result is literal when possible at M4 time, but must be
# used with eval if EXPRESSION causes shell indirections.
#
AC_DEFUN([ASX_TR_ARG],
  [AS_LITERAL_IF([$1],
     [m4_translit(AS_TR_SH([$1]), [_A-Z], [-a-z])],
     [m4_bpatsubst(AS_TR_SH([$1]), [`$],
        [ | tr '_[]m4_cr_LETTERS[]' '-[]m4_cr_letters[]'`])])])

# ASX_VAR_APPEND_UNIQ(VARIABLE,
#                     [TEXT],
#                     [SEPARATOR])
# -----------------------------------------------------------------------------
# Emits shell code to append the shell expansion of TEXT to the end of the
# current contents of the polymorphic shell variable VARIABLE without
# duplicating substrings. The TEXT can optionally be prepended with the shell
# expansion of SEPARATOR. The SEPARATOR is not appended if VARIABLE is empty or
# unset. Both TEXT and SEPARATOR need to be quoted properly to avoid field
# splitting and file name expansion.
#
AC_DEFUN([ASX_VAR_APPEND_UNIQ],
  [AS_CASE([$3[]AS_VAR_GET([$1])$3],
     [*m4_ifnblank([$3], [$3$2$3], [$2])*], [],
     [m4_ifnblank([$3],[$3$3],[''])], [AS_VAR_APPEND([$1], [$2])],
     [AS_VAR_APPEND([$1], [$3]); AS_VAR_APPEND([$1], [$2])])])

# ASX_PREPEND_LDFLAGS([LDFLAGS],
#                     [LIBS],
#                     ...)
# -----------------------------------------------------------------------------
# Prepends the first argument LDFLAGS to each of the rest of the arguments
# LIBS and expands into a space separated list of the resulting strings. Each
# element of the resulting list is shell-quoted with double quotation marks.
#
AC_DEFUN([ASX_PREPEND_LDFLAGS], [m4_foreach([arg], m4_cdr($@), [ "$1 arg"])])

# ASX_VAR_SET_IF_NOT_YET(VARIABLE,
#                        [VALUE])
# -----------------------------------------------------------------------------
# Expands into a shell script that checks whether the shell variable VARIABLE
# is already set and sets it to the VALUE if it is not the case.
#
AC_DEFUN([ASX_VAR_SET_IF_NOT_YET],
  [AS_VAR_SET_IF([$1], [], [AS_VAR_SET([$1], [$2])])])