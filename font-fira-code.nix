{ config, lib, pkgs, ... }:
{
  programs.kitty.settings = {
    font_family = "Fira Code";
    font_size = "11.0";
    macos_thicken_font = "0.4";
  };

  home.packages = with pkgs; [
    fira-code fira-code-symbols
  ];
}
