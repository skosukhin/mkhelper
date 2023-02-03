#!/bin/sh

set -e

fn_notice ()
{
  test "x$silent" = xyes || echo "fshm (init): $1" >&2
}

fn_error ()
{
  echo "fshm (init): error: $2" >&2 && exit $1
}

# Default values:
root=${FSHM_ROOT-unknown}
timeout=1
silent=no
hash_cmd='md5sum "${key_file}" | awk '\''{ print $1 }'\'
copy_cmd='rsync -az "${src_dir}/" "${dst_dir}"'
bucket_size=5
access_timeout=3
log_access=no

# Help message values:
help_timeout=$timeout
help_hash_cmd=$hash_cmd
help_copy_cmd=$copy_cmd
help_bucket_size=$bucket_size
help_access_timeout=$access_timeout

# Configuration variables:
config_var_prefix='fshm_'
config_vars='
hash_cmd
copy_cmd
bucket_size
access_timeout
log_access
'
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

Instantiates a filesystem hashmap in the specified directory. If the directory
exists and is already assigned to a hashmap, checks whether its configuraion is
matches the specified command-line options.

Defaults for the options are specified in brackets.

Command options:
  -h, --help        display this help and exit
  -r, --root        root directory of the hashmap storage [\$FSHM_ROOT]
  -t, --timeout     lock timeout in seconds for the initialization [$help_timeout]
  -s, --silent      do not emit notifications and warnings

Hashmap configuration options:
  --hash-cmd        hash command [$help_hash_cmd]
  --copy-cmd        copy command [$help_copy_cmd]
  --bucket-size     bucket size, i.e. the maximum number of keys that are
                    allowed to have the same cache [$help_bucket_size]
  --access-timeout  lock timeout in seconds for read/write operations [$help_access_timeout]
  --log-access      keep track of the requests to the hashmap

_EOF
      exit 0 ;;
    --root | -r)
      prev=root ;;
    --root=*)
      root=$optarg ;;
    --timeout | -t)
      prev=timeout ;;
    --timeout=*)
      timeout=$optarg ;;
    --silent | -s)
      silent=yes ;;
    --hash-cmd )
      prev=hash_cmd ;;
    --hash-cmd=*)
      hash_cmd=$optarg ;;
    --copy-cmd)
      prev=copy_cmd ;;
    --copy-cmd=*)
      copy_cmd=$optarg ;;
    --bucket-size)
      prev=bucket_size ;;
    --bucket-size=*)
      bucket_size=$optarg ;;
    --access-timeout)
      prev=access_timeout ;;
    --access-timeout=*)
      access_timeout=$optarg ;;
    --log-access)
      log_access=yes ;;
    *)
      fn_error 2 "unrecognized option: '$option': try '$0 --help' for more information" ;;
  esac
done
test -z "$prev" || fn_error 2 "missing argument to $option"

if test "x$root" = xunknown; then
  fn_error 2 "missing path to the root directory: specify the '--root' option or set the FSHM_ROOT environment variable"
else
  case $root in
    [\\/]* | ?:[\\/]*) ;;
    *) fn_error 2 "root '$root' must be set as an absolute path"
  esac
fi

mkdir -p "$root" || fn_error 2 "failed to create the root directory for the hashmap"

config_dir="$root/.fshm"
config_file="$config_dir/config_file"
if mkdir "$config_dir" 2>/dev/null; then
  fn_notice "initializing the hashmap in '$root'..."
  {
    for var in $config_vars; do
      eval value=\$$var
      case $value in
        *\'*)
          value=`echo "$value" | sed "s/'/'\\\\\\\\''/g"` ;;
        *) ;;
      esac
      echo "$config_var_prefix$var='$value'"
    done
  } >"$config_file~" && \
    chmod a-w "$config_file~" && \
    mv "$config_file~" "$config_file" && \
    chmod a-w "$config_dir" || \
    fn_error 2 "failed to create configuration file in '$config_dir'"
  fn_notice "the initialization is finished successfully"
else
  timeout_max_count=1
  timeout_count=0
  while :; do
    if test -f "$config_file"; then
      fn_notice "checking the configuraion of the existing hashmap in '$root'..."
      (
        config=`cat "$config_file"` || fn_error 2 "failed to read configuration file '$config_file'"
        eval "$config"
        for var in $config_vars; do
           eval "test \"x\$$config_var_prefix$var\" = \"x\$$var\" || fn_error 2 \"configuration mismatch for $var: \\\`\$$config_var_prefix$var\\\` != \\\`\$$var\\\`\""
        done
      ) && fn_notice "the configuraion is compatible"
      exit 0
    elif test $timeout_count -ge $timeout_max_count; then
      fn_error 2 "failed to initialize the hashmap in '$root': time limit exceeded"
    elif test -d "$config_dir"; then
      fn_notice "the hashmap is being initialized in '$root' by a parallel process: waiting $timeout second(s)"
      sleep $timeout
    else
      fn_error 2 "failed to initialize the hashmap in '$root' for unknown reasons"
    fi
    timeout_count=`expr $timeout_count + 1`
  done
fi
