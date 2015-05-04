#!/bin/bash

DULL=0
BRIGHT=1

FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_VIOLET=35
FG_CYAN=36
FG_WHITE=37

FG_NULL=00

BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_VIOLET=45
BG_CYAN=46
BG_WHITE=47

BG_NULL=00

##
# ANSI Escape Commands
##
ESC="\033"
RESET='0m'

##
# Shortcuts for Colored Text ( Bright and FG Only )
##

# DULL TEXT

BLACK="${DULL};${FG_BLACK}m"
RED="${DULL};${FG_RED}m"
GREEN="${DULL};${FG_GREEN}m"
YELLOW="${DULL};${FG_YELLOW}m"
BLUE="${DULL};${FG_BLUE}m"
VIOLET="${DULL};${FG_VIOLET}m"
CYAN="${DULL};${FG_CYAN}m"
WHITE="${DULL};${FG_WHITE}m"

# BRIGHT TEXT
BRIGHT_BLACK="${BRIGHT};${FG_BLACK}m"
BRIGHT_RED="${BRIGHT};${FG_RED}m"
BRIGHT_GREEN="${BRIGHT};${FG_GREEN}m"
BRIGHT_YELLOW="${BRIGHT};${FG_YELLOW}m"
BRIGHT_BLUE="${BRIGHT};${FG_BLUE}m"
BRIGHT_VIOLET="${BRIGHT};${FG_VIOLET}m"
BRIGHT_CYAN="${BRIGHT};${FG_CYAN}m"
BRIGHT_WHITE="${BRIGHT};${FG_WHITE}m"

# REV TEXT as an example
REV_CYAN="${DULL};${BG_WHITE};${BG_CYAN}m"
REV_RED="${DULL};${FG_YELLOW}; ${BG_RED}m"

# Echo "root" if the current user has root privs.  This is used to set my PS1, I
# think, so I know I'm root.
disp_root_name() {
    if [ `whoami` = "root" ]; then
        printf "root"
    fi
}

# Print out the number of jobs running with an argument format-string suitable
# for printf.  A default format-string is provided if there is no such
# argument.  I use this to get an "(n jobs)" string in my prompt.
num_jobs() {
    local num_jobs
    num_jobs="$(jobs | wc -l)"
    if [ $num_jobs -ne 0 ]; then
        if [ -n "$1" ]; then
            printf $1 $num_jobs
        else
            if [ $num_jobs -eq 1 ]; then
                printf " (1 job)"
            else
                printf " (%s jobs)" $num_jobs
            fi
        fi
    fi
}

GIT_WITNESS=".git"
GIT_NAME="git"
SVN_WITNESS=".svn"
SVN_NAME="svn"
CVS_WITNESS="CVS"
CVS_NAME="CVS"
DARCS_WITNESS="_darcs"
DARCS_NAME="darcs"

# Echoes a human-readable string of the revision control method; I use the
# output in my bash prompt.
vc_method() {
    local name
    if git show HEAD >/dev/null 2>&1; then
        name="$GIT_NAME$(__git_ps1 " on %s")"
    elif [ -d $SVN_WITNESS ]; then
        name="$SVN_NAME"
    elif [ -d $CVS_WITNESS ]; then
        name="$CVS_NAME"
    elif [ -d $DARCS_WITNESS ]; then
        name="$DARCS_NAME"
    fi

    if [ -n "$name" ]; then
        if [ -n "$1" ]; then
	    printf "$1" "$name"
        else
	    printf " (%s)" "$name"
        fi
    fi

}

# Echoes a short string indicating whether the shell variables 'http_proxy' and
# 'HTTPS_PROXY' have been set.  Again, this is used for my bash prompt.
disp_proxy_info() {
    local str
    if [ -n "$http_proxy" ]; then
        str="${str}h"
    fi
    if [ -n "$HTTPS_PROXY" ]; then
        str="${str}H"
    fi

    if [ -n "$str" ]; then
        printf "%s " "$str"
    fi
}

# echo "\[\033[${RED}`date`\]" "[$(whoami)@$(pwd)]" $(vc_method "%s")
echo "[$(whoami)@$(pwd)]" "$(hostname)" "`date`" $(vc_method "%s")
dirs
