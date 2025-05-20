{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.kitty.settings = {
    font_family = "SF Mono Regular";
    font_size = lib.mkDefault "11.0";
  };
}
