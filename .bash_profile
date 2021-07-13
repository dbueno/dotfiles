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

# opam configuration
test -r /Users/dbueno/.opam/opam-init/init.sh && . /Users/dbueno/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

[[ -e "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
[[ -e "$HOME/.bash_profile_local" ]] && source "$HOME/.bash_profile_local"

history -a
