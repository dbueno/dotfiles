{ config, lib, pkgs, ... }:
{
  programs.kitty.settings = {
    font_family = "IBM Plex Mono";
    font_size = "11.0";
  };

  home.packages = with pkgs; [
    ibm-plex
  ];
}
