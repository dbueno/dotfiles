{ config, lib, pkgs, ... }:
{
  imports = [ ./i3.nix ];

  firefox.enable = true;
}
