{ config, lib, pkgs, ... }:
{
  home.file = {
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };

  programs.git = {
    extraConfig = {
      diff = {
        tool = "kitty";
        guitool = "kitty.gui";
      };
    };
  };

  home.packages = with pkgs; [
  ];
}
