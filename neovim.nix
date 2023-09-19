{ config, lib, pkgs, ... }:
let
  my-vim-tweaks = pkgs.vimUtils.buildVimPlugin {
    pname = "denisbueno-vim-tweaks.vim";
    version = "dev";
    src = ./dotvim;
  };
  my-vimoutliner = pkgs.vimUtils.buildVimPlugin rec {
    pname = "vimoutliner";
    version = "8c8b79700068482c6357626f2eae86fb68878d5b";
    src = pkgs.fetchFromGitHub {
      owner = "dbueno";
      repo = "${pname}";
      rev = "${version}";
      sha256 = "8uD1dflyI8fn2rzk0l7aBHn6kOTGrpWKtsFv1p2oDXQ=";
    };
  };
in {

  programs.neovim = {
    enable = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      clang-tools
      clang
    ];
    plugins = with pkgs.vimPlugins; [
      my-vim-tweaks
      my-vimoutliner
      vim-fugitive
      vim-nix
      vim-commentary
      tabular
      vim-surround
      securemodelines
      editorconfig-vim

      plenary-nvim
      telescope-nvim

      nvim-lspconfig
      lsp_extensions-nvim
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      nvim-cmp
      lsp_signature-nvim
      nvim-treesitter

      cmp-vsnip
      vim-vsnip

      vim-rooter
      fzf-vim
    ];
    extraConfig = builtins.readFile ./config/nvim/vimrc
    + ''
      set completeopt=menuone,noinsert,noselect

      set cmdheight=2

      set updatetime=300


    '';
  };
}
