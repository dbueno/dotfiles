# Imported on every host; applies only on Linux. It must not set
# nixpkgs.overlays: pkgs, which the condition reads, depends on them.
{
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    home.packages = with pkgs; [
      hack-font
      perf
    ];
  };
}
