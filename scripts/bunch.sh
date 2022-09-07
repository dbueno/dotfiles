# Bunches stdin lines into groups in multiple output files. Each new output
# file is based on a trigger, which is just some text (not a regex,
# currently). Every time a line matches the trigger a new output file is
# created and subsequent input is echoed to that output file.

usage() { echo  "Usage: $0 [-d dir] trigger extension" 1>&2; exit 1; }

dir=""
while getopts d: flag
do
    case "''${flag}" in
        d) dir=''${OPTARG};;
        *) usage;
    esac
done
shift $((OPTIND-1))

trigger="$1"
ext="$2"

if test -z "$trigger" || test -z "$ext"; then
    usage
fi
#echo $trigger $ext $dir
i=0
test -n "$dir" && cd "$dir"
exec &> $i.$ext
while read; do
    if [[ "$REPLY" == *$trigger* ]]; then
        i=$((i+1))
        exec &> $i.$ext
    fi
    echo $REPLY
done
