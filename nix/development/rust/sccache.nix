# sccache, plus sccache-rustc for RUSTC_WRAPPER. direnv's `use sccache`
# (home-files/.config/direnv/lib/sccache.sh) turns it on per project.
{ pkgs, ... }:
let
  # Unreleased main: SCCACHE_BASEDIRS strips basedirs from env! values such as
  # OUT_DIR, so crates with build scripts (and everything built on them) share
  # entries across per-worktree target dirs. 0.19.0 still misses them.
  sccache = pkgs.sccache.overrideAttrs (
    finalAttrs: old: {
      version = "0.19.0-unstable-2026-11-14";
      src = pkgs.fetchFromGitHub {
        owner = "mozilla";
        repo = "sccache";
        rev = "ef8e7d76f9ce765df48ba40492be941be24695bf";
        hash = "sha256-od/u4JREomkZ+uXT/qU+4zs5e/S3Tcnj8UTIMmq1fG8=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = "sha256-+f2Mc74MC252OwY/LmwveLZUzgK8DeJ5O+1rukUQqmI=";
      };
    }
  );
  # sccache hashes CARGO_* env vars into its keys, so a per-worktree
  # CARGO_TARGET_DIR keeps worktrees from sharing entries. rustc doesn't need
  # it, so drop it there.
  sccache-rustc = pkgs.writeScriptBin "sccache-rustc" ''
    #!/bin/sh
    unset CARGO_TARGET_DIR
    exec ${sccache}/bin/sccache "$@"
  '';
in
{
  home.packages = [
    sccache
    sccache-rustc
  ];
}
