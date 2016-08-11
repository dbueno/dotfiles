#!/bin/sh

size_mb=32

diskutil erasevolume HFS+ 'lilram' `hdiutil attach -nomount ram://$((size_mb*2048))`
