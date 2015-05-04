#!/bin/bash

BV="/Volumes/J"
HBV="$BV/home"

backup() {
    local from="$1"
    local to="$2"

    if ! test -d "$1"; then
        echo "Warning: cannot backup \`$from', it doesn't exist"
    else
        echo "Backing up" "$from" "..."
        sleep 1
        rsync -av --progress --exclude-from=backup.exclude "$from" "$to"
    fi
}

if ! test -d "$BV"; then
    echo "!!! Error: backup volume \`$BV' does not exist, aborting" 1>&2
    exit 1
fi

mkdir -p "$HBV"

backup "$HOME/work" "$HBV/"

