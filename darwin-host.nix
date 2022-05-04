{ config, lib, pkgs, ... }:
{
  programs.vim = {
    packageConfigurable = pkgs.vim_configurable.override { darwinSupport = true; guiSupport = false; };
  };

  programs.kitty.settings = {
    font_family = "SF Mono Medium";
    font_size = "13.0";
  };

  programs.git.extraConfig.core.fsync = "all";
}
