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
mkdir -p "$HOME/"{code,papers,docs,benchmarks,writing}
mkdir -p "$HOME/work/"{inprogress,submitted,published}
mkdir -p "$HOME/.mutt" "$HOME/.mutt/cache/bodies" "$HOME/.mutt/cache/headers"
mkdir -p "$HOME/tmp"

mkdir -p "$HOME/sw/bin"
${INSTALL} ${INSTALL_FLAGS} "${PWD}/wtf" "$HOME/sw/bin/wtf"
${INSTALL} ${INSTALL_FLAGS} "${PWD}/wtf" "$HOME/sw/bin/erg"

${INSTALL} ${INSTALL_FLAGS}   \
    "${PWD}/.bashrc"          \
    "${PWD}/.bash_profile"    \
    "${PWD}/.bash_completion" \
    "${PWD}/.inputrc"         \
    "${PWD}/.Xresources"      \
    "${PWD}/.tmux.conf"       \
    "${PWD}/.tmux-macosx"     \
    "${PWD}/.tmux-linux"      \
    "${PWD}/.mailcap"         \
    "${PWD}/.ghci"            \
    "${PWD}/.gdbinit"         \
    "${PWD}/lispwords"        \
    "$HOME"

mkdir -p $HOME/.hammerspoon
${INSTALL} ${INSTALL_FLAGS} \
    "${PWD}/hammerspoon.lua" \
    "$HOME/.hammerspoon/init.lua"

mkdir -p $HOME/.config/kitty
${INSTALL} ${INSTALL_FLAGS} \
    "${PWD}/kitty.conf" \
    "${PWD}/kitty-nord-theme.conf" \
    "$HOME/.config/kitty"

mkdir -p $HOME/.config/nixpkgs
${INSTALL} ${INSTALL_FLAGS} \
    "${PWD}/config.nix" \
    "$HOME/.config/nixpkgs"

# copy this because otherwise our merges can screw up if there is a conflict in
# .gitconfig. Also, I feel better putting user info only in local file
cp "${PWD}/.gitconfig" "$HOME/"

# Ask for my name, email, update programs.
if ! git config --get user.name &> /dev/null; then
    echo 'Setting git name and email'
    printf 'Name: '
    read real_name
    git config --global user.name "${real_name}"
fi
if ! git config --get user.email &> /dev/null; then
    printf 'Email: '
    read email
    git config --global user.email "${email}"
fi
git config --global core.excludesfile ~/.gitignore_global

