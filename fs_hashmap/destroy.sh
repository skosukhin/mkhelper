#!/bin/sh

set -e

fn_notice ()
{
  test "x$silent" = xyes || echo "fshm (destroy): $1" >&2
}

fn_error ()
{
  echo "fshm (destroy): error: $2" >&2 && exit $1
}

fn_warn ()
{
  test "x$silent" = xyes || echo "fhsm (destroy): warning: $1" >&2
}

# Default values:
root=unknown
silent=no

prev=
for option; do
  if test -n "$prev"; then
    eval $prev=\$option
    prev=
    continue
  fi

  optarg=
  case $option in
    *=?*) optarg=`expr "X$option" : '[^=]*=\(.*\)'` ;;
  esac

  case $option in
    --help | -h)
      cat <<_EOF
Usage: $0 [OPTION]...

Removes a filesystem hashmap from the specified directory (together with the
directory).

Defaults for the options are specified in brackets.

Command options:
  -h, --help        display this help and exit
  -r, --root        root directory of the hashmap storage
  -s, --silent      do not emit notifications and warnings

_EOF
      exit 0 ;;
    --root | -r)
      prev=root ;;
    --root=*)
      root=$optarg ;;
    --silent | -s)
      silent=yes ;;
    *)
      fn_error 2 "unrecognized option: '$option': try '$0 --help' for more information" ;;
  esac
done
test -z "$prev" || fn_error 2 "missing argument to $option"

if test "x$root" = xunknown; then
  fn_error 2 "missing path to the root directory: specify the '--root' option"
else
  case $root in
    [\\/]* | ?:[\\/]*) ;;
    *) fn_error 2 "root '$root' must be set as an absolute path"
  esac
fi

test -d "$root/.fshm" || fn_error 2 "'$root' does not contain a hashmap"

chmod -R u+Xrw "$root" || fn_warn "failed to reset filesystem permissions for '$root'"

rm -r "$root" || fn_error 2 "failed to remove '$root'"

fn_notice "'$root' is successfully removed"
