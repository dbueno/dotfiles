{ config, lib, pkgs, ... }:
let
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon/default.nix {};
in
{
  imports = [ ./font-intel-one-mono.nix ];

  nixpkgs.overlays = [ (import ./overlays/vim-git.nix) ];

  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override { darwinSupport = true; guiSupport = false; };
  };

  # programs.kitty.settings = {
    # font_family = "SF Mono Regular";
    # font_size = "11.0";
    # macos_thicken_font = "0.5";
  # };

  programs.git.extraConfig.core.fsync = "all";

  programs.matplotlib.config.backend = "MacOSX";

  home.file = {
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };
  home.packages = with pkgs; [
    hammerspoon
  ];
}
