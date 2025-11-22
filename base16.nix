{
  config,
  lib,
  pkgs,
  ...
}:
let
  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "master";
    hash = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
  };
  pkg = {
    stdenv,
    lib,
    base16-shell,
    rwm-base16_synthwave-84
  }:
  stdenv.mkDerivation {
    pname = "base16-shell-customizations";
    version = "dev";
    srcs = [base16-shell rwm-base16_synthwave-84];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out
      cp -r source/* $out
      cp rwm-source/*.sh $out/scripts/
    '';
  };
  base16-shell-customizations = pkgs.callPackage pkg {
    inherit base16-shell;
  };
in
  {
  home.file = {
    "${config.xdg.configHome}/base16-shell" = {
      source = base16-shell-customizations;
      recursive = true;
    };
  };
}
