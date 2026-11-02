# Graphical applications, for hosts with a display.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  skim-app = pkgs.callPackage ../pkgs/skim-app/default.nix { };
in
{
  options.dotfiles.gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to install graphical applications.";
  };

  config = lib.mkIf config.dotfiles.gui.enable {
    home.packages = lib.optional pkgs.stdenv.hostPlatform.isDarwin skim-app;
  };
}
