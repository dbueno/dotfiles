{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./fonts/font-hack.nix];

  programs.kitty.settings = {
    font_size = "9.0";
  };

  home.packages = with pkgs; [
    linuxPackages.perf
  ];
}
