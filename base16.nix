
{
  config,
  lib,
  pkgs,
  ...
}:
let
  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "master";
    hash = "sha256-X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
  };
in
  {
  home.file = {
    "${config.xdg.configHome}/base16-shell" = {
      source = base16-shell;
      recursive = true;
    };
  };
}
