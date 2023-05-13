{ config, lib, pkgs, ... }:
let
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon/default.nix {};
in
{
  imports = [ ./font-intel-one-mono.nix ];

  nixpkgs.overlays = [ ];

  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override { darwinSupport = true; guiSupport = false; };
  };

  programs.kitty.settings = {
    text_gamma_adjustment = "1.7";
    text_contrast = "30";
  };

  programs.git.extraConfig.core.fsync = "all";

  programs.matplotlib.config.backend = "MacOSX";

  home.file = {
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };
  home.packages = with pkgs; [
    hammerspoon
  ];
}
