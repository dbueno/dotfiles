{ config, lib, pkgs, ... }:
{
  programs.kitty.settings = {
    font_family = "Inconsolata";
    font_size = "11.0";
  };

  home.packages = with pkgs; [
    inconsolata
  ];
}
