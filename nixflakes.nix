result: prev: {
nixFlakes =
    (prev.writeShellScriptBin "nixFlakes" ''
        exec ${result.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '');
}

