#!/bin/sh

set -x

now=`date '+%Y-%m-%dT%H%M'`
bloc="/Volumes/BAK"


cd $HOME && gnutar --exclude-tag-all=tarexclude -cvz work Documents | gzip - | split -b $((4*1024*1024*1024-1)) - "$bloc/hermbak-$now.tar.gz"
