{ config, lib, pkgs, ... }:
let
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon/default.nix {};
  stats = pkgs.callPackage ./pkgs/stats/default.nix {};
  skim-app = pkgs.callPackage ./pkgs/skim-app/default.nix {};
in
{
  imports = [ ./fonts/font-ibm-plex.nix ];

  nixpkgs.overlays = [ ];

  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override { darwinSupport = true; guiSupport = false; };
  };

  programs.git.extraConfig.core.fsync = "all";

  programs.matplotlib.config.backend = "MacOSX";

  home.file = {
    ".hammerspoon/init.lua".source = ./config/hammerspoon.lua;
  };
  home.packages = [
    hammerspoon
    stats
    skim-app
  ];
}
