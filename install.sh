#!/bin/bash

# Install various useful configuration files for my shell environment and other
# programs.
#
# By default these are installed via symlinks into the repo, but passing the
# '--copy' options forces them to be copied.

INSTALL=ln
INSTALL_FLAGS=-sf

EMACS_SITE="${HOME}/.emacs.d/site-lisp"

for i in $*
do
    case $i in
    	--copy)
	INSTALL=cp
        INSTALL_FLAGS=
	;;
    	*)
            echo "Unrecognised option:" "\`$i'" "Stop."
            exit 1
	    ;;
    esac
done

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/sw"
mkdir -p "$HOME/{code,papers,docs,benchmarks,writing}"
mkdir -p "$HOME/work/{inprogress,submitted,published}"
mkdir -p "$HOME/.mutt" "$HOME/.mutt/cache/bodies" "$HOME/.mutt/cache/headers"

${INSTALL} ${INSTALL_FLAGS} "${PWD}/wtf" "$HOME/sw/bin/wtf"
${INSTALL} ${INSTALL_FLAGS} "${PWD}/wtf" "$HOME/sw/bin/erg"

${INSTALL} ${INSTALL_FLAGS}                        \
    "${PWD}/.bashrc"                              \
    "${PWD}/.inputrc"                              \
    "${PWD}/.Xresources"                           \
    "${PWD}/.tmux.conf"                            \
    "${PWD}/.tmux-macosx"                            \
    "${PWD}/.tmux-linux"                            \
    "${PWD}/.mailcap"                            \
    "${PWD}/.ghci"                            \
    "${PWD}/.gdbinit"                            \
    "$HOME"


# copy this because otherwise our merges can screw up if there is a conflict in
# .gitconfig
cp "${PWD}/.gitconfig" "$HOME/"

# Ask for my name, email, update programs.
echo 'Setting git name and email'
printf 'Name: '
read real_name
printf 'Email: '
read email
git config --global user.name "${real_name}"
git config --global user.email "${email}"
git config --global core.excludesfile ~/.gitignore_global

