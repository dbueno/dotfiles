# Settings for interactive shells
# .bashrc is executed for interactive non-login shells

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
 
[[ -e "$HOME/.bashrc_personal" ]] && source "$HOME/.bashrc_personal"

alias c=clear

my_uname="$(uname)"

## OS-dependent aliases, Darwin first
if [ $my_uname = "Darwin" ]
then
    function a { CLICOLOR_FORCE=1 ls -lFGtrh "$@" | tail -n 20 && echo "[showing at most 20 files]"; }
    alias aa='ls -lFGtrh'
    alias mk="make -j$(sysctl -a | grep ^hw[.]ncpu | cut -d' ' -f2)"
    alias lldb='PATH=/usr/bin:$PATH lldb'


## Linux-dependent aliases
elif [ $my_uname = "Linux" -o $my_uname = "CYGWIN_NT-5.1"  -o $my_uname = "MINGW32_NT-5.1" ]
then
    function a { ls -lF --color -trh "$@" | tail -n 20 && echo "[showing at most 20 files]"; }
    alias aa='ls -lF --color -trh'
    alias mk='make'
#else
#    echo "Unrecognized host (i.e. not Darwin or Linux). Run 'uname'."
fi



# there's always a story behind aliases like these
alias rm='rm -i'
alias pd='cd "$OLDPWD"'
#alias packet_dump="sudo /usr/sbin/tcpdump -a -i en1 -vvv -XX -s 1500"
#alias rmws="awk '{sub(/[ \t]+$/, \"\");print}'"

# Evaluates to an iso-conformant date.  The iso-conformance is good because
# lexicographic order coincides with date order.  'nows' just has seconds and
# is also iso-conformant.
alias now="date '+%Y-%m-%dT%H%M'"
alias nows="date '+%Y-%m-%dT%H%M%S'"
alias today="date '+%Y-%m-%d'"

# example: makeiso -V vol_id -o output_filename
#alias makeiso="mkisofs -l -pad -U -J -r -allow-leading-dots -iso-level 4"

# grabhttp is for mirroring a website onto a drive.  example: grabhttp --level=2
#alias grabhttp="wget -v -F -N -x --cache=off --recursive --convert links"

# git aliases
function s {
    git status -uno || return
    git status --short | awk '/[?][?]/ { c += 1 } END { if (c > 0) { printf("\n... and %s untracked files\n", c) } }' || return
}
function ss { git status; }
alias gp='git pull'
alias gx='git pull && git push'
alias ga='git add -p'
alias gci='git commit'
# print git directory, toplevel of current repo
alias pgd='git rev-parse --show-toplevel'

# uses universal-ctags or something
alias make_cpptags='ctags --c++-kinds=+pf --c-kinds=+p --fields=+imaSft --extra=+q -Rnu'

## Adds to path but only if it's not there
function add_to_path {
  path="$1"
  [ -d "$path" ] && [[ $PATH != *"$path"* ]] && PATH="$path:$PATH"
}

# bash completion from homebrew
if command -v brew >/dev/null 2>&1; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
    source $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
    
    if test -d $(brew --prefix)/opt/fzf/shell; then
        source $(brew --prefix)/opt/fzf/shell/completion.bash
        source $(brew --prefix)/opt/fzf/shell/key-bindings.bash
    fi
else
    __git_ps1() {
        :;
    }
fi

# Kitty bash completion.
if [[ "$TERM" = *"kitty"* ]]; then
    source <(kitty + complete setup bash)
fi


export EDITOR="vim"
export ED="$EDITOR"

function add_cwd_to_path {
  path="$(pwd)"
  # Checks f or the presence of the string in PATH before adding.
  # Ideally, we would check whether $path is a PATH entry, not whether the string is there
  [ -d "$path" ] && [[ $PATH != *"$path"* ]] && PATH="$path:$PATH" || \
    printf "path '%s' not added\n" "$path"
}


# Prompt settings #############################################################

# Print out the number of jobs running with an argument format-string suitable
# for printf.  I use this to get an "(n jobs)" string in my prompt.
num_jobs() {
    local num_jobs
    num_jobs="$(jobs | wc -l)"
    if [ $num_jobs -ne 0 ]; then
        printf "%s > " $num_jobs
    fi
}

# For Linux, pretty colors.
#export LS_COLORS='di=00;36;40:ln=00;35:ex=00;31'
# For mac, pretty colors.
#export LSCOLORS="gxfxcxdxbxegedabagacad"


# Shell settings
###############################################################################
# Ctrl-D shouldn't exit the shell.  Annoying.
set -o ignoreeof
# Correct transpositions and other minor details from 'cd DIR' command.
shopt -s cdspell
# Include hidden files in glob (*).
shopt -s dotglob
# Extra-special pattern matching in the shell.
shopt -s extglob
# Flatten multiple-line commands into the same history entry.
shopt -s cmdhist
# Don't complete when I haven't typed anything.
shopt -s no_empty_cmd_completion
# Let me know if I shift stupidly.
shopt -s shift_verbose

# The & removes dups; [ ]* ignores commands prefixed with spaces.  Other
# commands, like job control and ls'ing are also ignored.
export HISTIGNORE="&:[ ]*:exit:[bf]g:no:lo:lt:pd:c:a:s"
export HISTSIZE=1000000
export LASTDIR="$HOME"
 
# [[ -z "$PROMPT_COMMAND_ORIG" ]] && export PROMPT_COMMAND_ORIG="$PROMPT_COMMAND"
# function bueno_prompt_command {
#   history -a
 
#   # Record new directory on change.
#   newdir=`pwd`
#   if [ ! "$LASTDIR" = "$newdir" ]; then
#     # List contents:
#     ls -tF | head -7
#   fi
 
#   export LASTDIR=$newdir
# }
# export PROMPT_COMMAND="${PROMPT_COMMAND_ORIG:+$PROMPT_COMMAND_ORIG; }bueno_prompt_command"

# When I type 'cd somewhere', if somewhere is relative, try out looking into all
# the paths in $CDPATH for completions.  This can speed up common directory
# switching.
#
# The . is here so that if I type cd <dir> it goes to curdir first
export CDPATH=".:$HOME/work/inprogress"

# Colors the prompt red if the last command doesn't exit cleanly.
function __colorcode_exit {
    if test $? -eq 0; then
        printf ";"
    else
        printf "\[\033[01;31m\];\[\033[0m\]"
    fi
}

function __colorcode_setps1 {
    history -a
    # I tried, at first, setting PS1 in .bashrc alone. But I ran into a problem
    # where the \[ and \] in __colorcode_exit were being literally printed in
    # the prompt, instead of interpreted as directives for bash. Setting PS1 in
    # PROMPT_COMMAND fixes this problem.
    PS1="$(__colorcode_exit) "
}

function bueno_minimalist_prompt {
    PROMPT_COMMAND='__colorcode_setps1'
}

function bueno_verbose_prompt {
    export PS1='\[\033[0;31m\]$(hostname -s) @ \w$(__git_ps1 " (%s)") ====================================== [ \! \# ]\[\033[0m\]
\j | \A $ '
}

bueno_minimalist_prompt
