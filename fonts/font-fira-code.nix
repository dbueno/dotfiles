{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.kitty.settings = {
    font_family = "Fira Code";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];
}
