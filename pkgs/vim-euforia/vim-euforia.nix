{ config, lib, pkgs, ... }:
let
  vim-euforia = pkgs.vimUtils.buildVimPlugin rec {
    pname = "euforia.vim";
    version = "master";
    src = builtins.fetchGit {
      url = "ssh://git@github.com/greedy/vim-euforia.git";
      rev = "96ee4c9c7296dbb75f7e927e93e4576dec1c898e";
    };
  };
in {

  programs.vim.plugins = [
    vim-euforia
  ];

}
