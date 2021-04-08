# Denis Bueno's .bash_profile <dbueno@gmail.com>
# Please feel free to crib what you like.  Letting me know is nice.

# .bash_profile is run for login shells

# [[ $- != *i* ]] && return
# [[ -z "$TMUX" ]] && exec tmux

# Errant and promiscuous LD_LIBRARY_PATHs can wreak havoc.  Destroy.
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH

# sometimes I need to override existing stuff w/ stuff in bin.
PATH="$HOME/bin:$PATH"

# OCaml debugging stuff
#
# b prints backtraces when an exception causes abnormal program
# termination.
export OCAMLRUNPARAM="b"

## CVS Settings
export CVS_RSH=ssh


# From here on, we can depend on PATH being set.
################################################


# Environment variables #######################################################

my_whoami=`whoami`
if [ $my_whoami = "root" ]
then
    # Timeout a root login if there is no input for five minutes.
    TMOUT=$(( 60 * 5 ))
fi

export CPATH
export LIBRARY_PATH
export LD_LIBRARY_PATH DYLD_LIBRARY_PATH
# export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH
export PATH PYTHONPATH
export LD_LIBRARY_PATH
export CLASSPATH

# Report unset variables if they are used.
# set -o nounset
# Apparently there is no way to check if a variable is initialised. This option
# is essentially useless for some scripts. And bash_completion, when you run
# tab completion, errors.

# OPAM configuration
# OPAM_FILE=/Users/dbueno/.opam/opam-init/init.sh
# [[ -e "$OPAM_FILE" ]] && . "$OPAM_FILE" >&/dev/null

# Colors the prompt red if the exit code argument isn't 0.
function __colorcode_exit {
    if test "$1" -eq 0; then
        # printf ";"
        printf "\[\033[01;32m\]:;\[\033[0m\]"
    else
        printf "\[\033[01;31m\]:;\[\033[0m\]"
    fi
}

function __colorcode_setps1 {
    local last_exit="$?"
    # I tried, at first, setting PS1 in .bashrc alone. But I ran into a problem
    # where the \[ and \] in __colorcode_exit were being literally printed in
    # the prompt, instead of interpreted as directives for bash. Setting PS1 in
    # PROMPT_COMMAND fixes this problem.
    PS1="$(__colorcode_exit $last_exit) "
}

function bueno_minimalist_prompt {
    PROMPT_COMMAND+=('__colorcode_setps1')
}

function bueno_verbose_prompt {
    export PS1='\[\033[0;31m\]$(hostname -s) @ \w$(__git_ps1 " (%s)") ====================================== [ \! \# ]\[\033[0m\]
\j | \A $ '
}

bueno_minimalist_prompt

# Perlbrew
# source ~/perl5/perlbrew/etc/bashrc
if [ -e /Users/dbueno/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/dbueno/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# opam configuration
test -r /Users/dbueno/.opam/opam-init/init.sh && . /Users/dbueno/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

[[ -e "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

history -a
