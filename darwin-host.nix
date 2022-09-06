{ config, lib, pkgs, ... }:
let
  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon/default.nix {};
in
{
  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override { darwinSupport = true; guiSupport = false; };
  };

  programs.kitty.settings = {
    font_family = "SF Mono Regular";
    font_size = "11.0";
  };

  programs.git.extraConfig.core.fsync = "all";

  home.file = {
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };
  home.packages = with pkgs; [
    hammerspoon
  ];
}
