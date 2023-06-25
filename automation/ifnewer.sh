#!/usr/bin/env bash

# Example: ninja && /Users/dbueno/bin/ifnewer.sh bin/exe /path/to/install/bin/exe ninja install

msg="usage: ifnewer.sh file fileref command [arg ...]
If file is newer than fileref, runs command."
if [ -z "$1" ]; then
    printf "%s\n" "$msg"
    exit 1
fi

file="$1"
shift
fileref="$1"
shift

if [ "$file" -nt "$fileref" ]; then
    ( "$@" )
fi
