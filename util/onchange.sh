#!/usr/bin/env bash

# TODO: Add option to watch a directory other than the current directory.

msg="usage: onchange.sh command [arg ...]
Arguments should be what you want to run when anything on the filesystem
changes (relative to current directory)."
if [ -z "$1" ]; then
    printf "%s\n" "$msg"
    exit 1
fi

# Runs command up front because usually this is what I want.
( "$@" ) # || exit 1

while true; do
    # fswatch returns exit code 0 regardless. If a file changes fswatch -1 will
    # print its name. Sets n to 1 if that happens.
    n=$(fswatch -1 . | wc -l | tr -d ' \t')
    if [[ $n -gt 0 ]]; then
        ( "$@" ) # || exit 1
    else
        exit 0
    fi
done
