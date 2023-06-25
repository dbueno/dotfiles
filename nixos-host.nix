{ config, lib, pkgs, ... }:
{
  imports = [ ./i3.nix ./fonts/font-ibm-plex.nix ];

  programs.firefox.enable = true;

  programs.kitty.settings = {
    font_size = "8.0";
  };
}
