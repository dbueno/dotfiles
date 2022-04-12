{ config, lib, pkgs, ... }:
{
  imports = [ ./i3.nix ];

  programs.firefox.enable = true;
}
