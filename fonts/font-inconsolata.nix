{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.kitty.settings = {
    font_family = "Inconsolata";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = with pkgs; [
    inconsolata
  ];
}
