#!/bin/bash

# Install various useful configuration files for my shell environment and other
# programs.

INSTALL=ln
INSTALL_FLAGS=-sf

mkdir -p "$HOME/"{code,papers,docs,benchmarks,writing}
mkdir -p "$HOME/work/"{inprogress,submitted,published}
mkdir -p "$HOME/.mutt" "$HOME/.mutt/cache/bodies" "$HOME/.mutt/cache/headers"


mkdir -p "$HOME/.config/nixpkgs"
${INSTALL} ${INSTALL_FLAGS} \
    "${PWD}/config.nix"     \
    "${PWD}/home.nix"       \
    "$HOME/.config/nixpkgs"

