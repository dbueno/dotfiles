{ config, lib, pkgs, ... }:
{
  home.file = {
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
  };

  home.packages = with pkgs; [
  ];
}
