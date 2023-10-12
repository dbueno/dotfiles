{ config, lib, pkgs, ... }:
{
  programs.kitty.settings = {
    font_family = "DejaVu Sans Mono";
    font_size = "9.0";
  };

  home.packages = with pkgs; [
    linuxPackages.perf
  ];
}
