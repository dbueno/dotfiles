{ config, lib, pkgs, ... }:
{
  programs.kitty.settings = {
    font_family = "Input Mono";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = with pkgs; [
    input-fonts
  ];
}
