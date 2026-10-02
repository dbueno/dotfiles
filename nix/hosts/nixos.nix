{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../home/i3.nix
    ../fonts/font-inconsolata.nix
  ];

  programs.firefox.enable = true;

  home.packages = [
  ];
}
