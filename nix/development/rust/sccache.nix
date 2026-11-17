# sccache, plus sccache-rustc for RUSTC_WRAPPER. direnv's `use sccache`
# (home-files/.config/direnv/lib/sccache.sh) turns it on per project.
{ pkgs, ... }:
let
  # sccache hashes CARGO_* env vars into its keys, so a per-worktree
  # CARGO_TARGET_DIR keeps worktrees from sharing entries. rustc doesn't need
  # it, so drop it there.
  sccache-rustc = pkgs.writeScriptBin "sccache-rustc" ''
    #!/bin/sh
    unset CARGO_TARGET_DIR
    exec ${pkgs.sccache}/bin/sccache "$@"
  '';
in
{
  home.packages = [
    pkgs.sccache
    sccache-rustc
  ];
}
