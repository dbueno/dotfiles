{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.kitty.settings = {
    font_family = "Hack";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = with pkgs; [
    hack-font
  ];
}
