{ config, lib, pkgs, ... }:
{

  home.packages = with pkgs; [
    (pkgs.callPackage ./pkgs/stats/default.nix {})
  ];
}
