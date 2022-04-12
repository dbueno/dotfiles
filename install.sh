#!/usr/bin/env bash
if nix flake metadata . > /dev/null 2>&1 ; then
    nixwithflakes=nix
elif nixFlakes flake metadata . > /dev/null 2>&1 ; then
    nixwithflakes=nixFlakes
else
    echo "Couldn't find a nix with flakes enabled. Tried nix and nixFlakes."
    exit 1
fi
linktmp="$(mktemp -d -t home-manager-install.XXXXXX)"
cleanuptmp () {
    rm -rf "$linktmp"
}
trap cleanuptmp EXIT
$nixwithflakes build -o "$linktmp/result" .#homeConfigurations.'"'"$USER@$(hostname)"'"'.activationPackage
"$linktmp/result/activate"
