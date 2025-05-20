{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.kitty.settings = {
    font_family = "Roboto Mono Medium";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = with pkgs; [
    roboto-mono
  ];
}
