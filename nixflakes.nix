result: prev: {
nixFlakes =
    (prev.writeShellScriptBin "nixFlakes" ''
        exec ${result.nix_2_4}/bin/nix --experimental-features "nix-command flakes" "$@"
    '');
}

