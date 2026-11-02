# defaults -currentHost write -g AppleFontSmoothing -int 0
#
# Imported on every host; applies only on Darwin. It must not set
# nixpkgs.overlays: pkgs, which the condition reads, depends on them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  stats = pkgs.callPackage ../pkgs/stats/default.nix { };
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.vim = {
      packageConfigurable = pkgs.vim_configurable.override {
        darwinSupport = true;
        guiSupport = false;
      };
    };

    programs.matplotlib.config.backend = "MacOSX";

    home.packages = [ stats ];
  };
}
