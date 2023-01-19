#!/bin/sh

script_dir=`dirname $0`
script_dir=`cd "$script_dir"; pwd`

( dir=$script_dir
  echo "Running autoreconf in '$dir'..." && cd "$dir" && autoreconf -fvi ) || exit $?

( dir="$script_dir/bundled/picky"
  echo "Running autoreconf in '$dir'..." && cd "$dir" && autoreconf -fvi ) || exit $?

( dir="$script_dir/bundled/config_subdir/build"
  echo "Running autoreconf in '$dir'..." && cd "$dir" && autoreconf -fvi ) || exit $?

( dir="$script_dir/bundled/threaded_hello"
  echo "Running autoreconf in '$dir'..." && cd "$dir" && autoreconf -fvi || exit $?
  patch --forward --no-backup-if-mismatch -p1 -r - -i "$script_dir/libtool_patches/libtool.m4.mpi_wrappers.patch"

  # The program 'patch' exits with exitcode=1 if the patch has already been applied.
  # Consider this a normal scenario:
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  patch --forward --no-backup-if-mismatch -p1 -r - -i "$script_dir/libtool_patches/libtool.m4.arg_spaces.patch"
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  patch --forward --no-backup-if-mismatch -p1 -r - -i "$script_dir/libtool_patches/libtool.m4.nag_convenience.patch"
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  patch --forward --no-backup-if-mismatch -p1 -r - -i "$script_dir/libtool_patches/libtool.m4.debian_no_overlink.patch"
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  autoconf -f || exit $?

  # Reset libtool.m4 timestamps to avoid confusing make if the latter
  # checks them (e.g. makefiles are generated with Automake):
  touch -r m4/ltversion.m4 m4/libtool.m4

  # The following patch modifies only ltmain.sh, so it does not require re-running autoconf:
  patch --forward --no-backup-if-mismatch -p1 -r - -i "$script_dir/libtool_patches/ltmain.sh.nag_pthread.patch"
  exitcode=$?; test $exitcode -ne 0 && test $exitcode -ne 1 && exit $exitcode

  # All went fine since we have not exited before:
  exit 0 ) || exit $?
