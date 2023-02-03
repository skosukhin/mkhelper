#!/bin/sh

set -e

fn_notice ()
{
  test "x$silent" = xyes || echo "fshm (get): $1" >&2
}

fn_error ()
{
  echo "fshm (get): error: $2" >&2 && exit $1
}

fn_warn ()
{
  test "x$silent" = xyes || echo "fhsm (get): warning: $1" >&2
}

fn_log_access()
{
  if test "x$fshm_log_access" = xyes; then
    echo "`date -u '+%Y%m%d%H%M%S'`	$2" >> "$1" || fn_warn "failed to append an access log entry to '$1'"
  fi
}

# Default values:
key=; unset key
root=${FSHM_ROOT-unknown}
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
Usage: $0 [OPTION]... KEY

Prints path to the directory associated with the KEY in the hashmap.

Positional arguments:
  KEY               path to a file representing the key

Command options:
  -h, --help        display this help and exit
  -r, --root        root directory of the hashmap storage [\$FSHM_ROOT]
  -s, --silent      do not emit notifications and warnings

Exit codes:
    0  the KEY exists in the hashmap
  100  the KEY does not exist in the hashmap

_EOF
      exit 0 ;;
    --root | -r)
      prev=root ;;
    --root=*)
      root=$optarg ;;
    --silent | -s)
      silent=yes ;;
    -*)
      fn_error 2 "unrecognized option: '$option': try '$0 --help' for more information" ;;
    *)
      if ${key+false} :; then
        key=$option
      else
        fn_error 2 "unexpected positional argument: '$option': try '$0 --help' for more information"
      fi ;;
  esac
done
test -z "$prev" || fn_error 2 "missing argument to $option"
${key+:} false || fn_error 2 "missing positional argument KEY"

if test "x$root" = xunknown; then
  fn_error 2 "missing path to the root directory: specify the '--root' option or set the FSHM_ROOT environment variable"
else
  case $root in
    [\\/]* | ?:[\\/]*) ;;
    *) fn_error 2 "root '$root' must be set as an absolute path"
  esac
fi

config_dir="$root/.fshm"
config_file="$config_dir/config_file"
config=`cat "$config_file"` || fn_error 1 "failed to read configuration file '$config_file'"
eval "$config"

test -r "$key" || fn_error 1 "key file '$key' not found"

key_file=$key
eval "hash=\`$fshm_hash_cmd\`"
key_dir_base="$root/$hash"

current_bucket_size=0
while test $current_bucket_size -lt $fshm_bucket_size; do
  key_dir="$key_dir_base-$current_bucket_size"
  timeout_max_count=1
  timeout_count=0
  while :; do
    if test -f "$key_dir/key"; then
      # The hashmap contains a key with the same hash:
      if cmp "$key_file" "$key_dir/key" >/dev/null 2>/dev/null; then
        # The keys are equal:
        fn_log_access "$key_dir/log" 'get'
        echo "$key_dir/value"
        exit 0
      else
        fn_notice "cache conflict for key '$key' detected: switching to the next slot in the bucket"
        break
      fi
    elif test $timeout_count -ge $timeout_max_count; then
      fn_error 2 "failed to get value for key '$key' from the hashmap: time limit exceeded"
    elif test -d "$key_dir"; then
      fn_notice "key '$key' is being inserted into the hashmap by a parallel process: waiting $fshm_access_timeout second(s)"
      sleep $fshm_access_timeout
    else
      fn_notice "key '$key' does not exist in the hashmap"
      exit 100
    fi
    timeout_count=`expr $timeout_count + 1`
  done
  current_bucket_size=`expr $current_bucket_size + 1`
done

fn_error 2 "failed to get value for key '$key' from the hashmap: bucket size limit exceeded"
