#!/bin/sh

autoreconf -fvi || exit $?

if test -f m4/libtool.m4; then
  # An example of how libtool patches can be applied:
  patch --forward --no-backup-if-mismatch -p1 -r - -i libtool_patches/libtool.m4.nag_wrapper.patch -d .

  # The program 'patch' exits with exitcode=1 if the patch has already been applied.
  # Consider this a normal scenario:
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  patch --forward --no-backup-if-mismatch -p1 -r - -i libtool_patches/libtool.m4.arg_spaces.patch -d .
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  # Rebuild configure if you need to patch M4 macros:
  autoconf -f || exit $?

  # Reset libtool.m4 timestamps to avoid confusing make if the latter
  # checks them (e.g. makefiles are generated with Automake):
  touch -r m4/ltversion.m4 m4/libtool.m4

  # The following patch modifies only ltmain.sh, so it does not require re-running autoconf:
  patch --forward --no-backup-if-mismatch -p1 -r - -i libtool_patches/ltmain.sh.nag_pthread.patch -d .
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode
fi
