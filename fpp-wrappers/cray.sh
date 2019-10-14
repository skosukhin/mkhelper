append_quoted ()
{
  appended_arg=$2
  case $appended_arg in
    *\'*) appended_arg=`echo "$appended_arg" | sed "s/'/'\\\\\\\\''/g"` ;;
  esac
  eval "$1=\"\$$1'\$appended_arg' \""
}

args=

# The first argument is supposed to be the compiler:
append_quoted args $1; shift
# Set the flag enabling preprocessing:
append_quoted args "-eP"

# Ideally, we would change the current working directory to a temporary one,
# run the compiler, and do something like 'cat ./*.i'. Unfortunately, this
# would make all relative paths that are, for example, set with -I flags
# invalid. On the other hand, it would require quite complex parsing of the
# arguments to figure out the full list of input files. Therefore, the list of
# input files for this wrapper is the longest sequence of arguments, each
# element of which is a path to an existing and readable file, that is found
# in the end of the command line. Another obvious limitation of the wrapper
# is that the input files must not have the same basename (e.g. ./test.f90
# ./somedir/test.f90).

output_files=
trap 'eval "rm -f $output_files"' EXIT

while test $# -gt 0; do
  opt=$1; shift
  case $opt in
# Filter out all options that cause compilation right after preprocessing:
    -e*Z*|-d*Z*|-e*T*|-d*T*)
      opt=`echo "$opt" | sed 's/[ZT]//g; s/^-[ed][ ]*$//'`
      test -n "$opt" && append_quoted args "$opt"
      output_files= ;;
# Filter out all options that cause compilation right after preprocessing:
    -e|-d)
      next_opt=$1; shift
      next_opt=`echo "$next_opt" | sed 's/[ZT]//g'`
      test -n "$next_opt" && append_quoted args "$opt" && \
      append_quoted args "$next_opt"
      output_files= ;;
    -*)
      append_quoted args "$opt"
      output_files= ;;
    *)
      append_quoted args "$opt"
      if test -f "$opt" && test -r "$opt"; then
        output_file_basename=`echo "$opt" | sed 's%.*/%%; s%\.[^.]*$%%'`
        case " $output_files " in
          *" '${output_file_basename}.i' "*)
            echo "The Fortran preprocessor wrapper for Cray '$0' received two \
input files with the same basename '$output_file_basename'." >&2 && exit 2 ;;
        esac
        append_quoted output_files "${output_file_basename}.i"
      else
        output_files=
      fi ;;
  esac
done

if test -n "$output_files"; then
  eval "rm -f $output_files"
else
  echo "The Fortran preprocessor wrapper for Cray '$0' could not recognize \
the list of output files from the command line." >&2 && exit 2
fi

eval "$args" || exit $?

eval "cat $output_files" || exit $?
