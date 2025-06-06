# defaults -currentHost write -g AppleFontSmoothing -int 0
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon/default.nix { };
  stats = pkgs.callPackage ./pkgs/stats/default.nix { };
  skim-app = pkgs.callPackage ./pkgs/skim-app/default.nix { };
in
{
  nixpkgs.overlays = [ ];

  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override {
      darwinSupport = true;
      guiSupport = false;
    };
  };

  programs.git.extraConfig.core.fsync = "all";

  programs.matplotlib.config.backend = "MacOSX";

  home.packages = [
    pkgs.ibm-plex
    pkgs.jetbrains-mono
    pkgs.iosevka-bin
    hammerspoon
    stats
    skim-app
    pkgs.obsidian
  ];
}
