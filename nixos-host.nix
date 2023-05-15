{ config, lib, pkgs, ... }:
{
  imports = [ ./i3.nix ./font-fira-code.nix ];

  programs.firefox.enable = true;

  programs.kitty.settings = {
    #font_family = "DejaVu Sans Mono";
    font_size = "8.0";
  };
}
