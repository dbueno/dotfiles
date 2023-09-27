{ config, lib, pkgs, ... }:
let
  my-vim-tweaks = pkgs.vimUtils.buildVimPlugin {
    pname = "denisbueno-vim-tweaks.vim";
    version = "dev";
    src = ./dotvim;
  };
  my-neovim-tweaks = pkgs.vimUtils.buildVimPlugin {
    pname = "denisbueno-neovim-tweaks.vim";
    version = "dev";
    src = ./neovim;
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
  tree-sitter-souffle-langston-barrett = pkgs.fetchFromGitHub {
    owner = "langston-barrett";
    repo = "tree-sitter-souffle";
    rev = "901e71368a29d5f893d43d099fbc2b4ab037660e";
    hash = "sha256-thUT+hi0lHnrpCuOe/bjlcM7ZfHruCDqN3YFOS3JCHA=";
  };
  nvim-treesitter-souffle-lyxell = pkgs.vimUtils.buildVimPlugin rec {
    pname = "nvim-treesitter-souffle";
    version = "81c0003447c61ee2c54aeea0f7ec934acf795061";
    src = pkgs.fetchFromGitHub {
      owner = "lyxell";
      repo = "${pname}";
      rev = "${version}";
      hash = "sha256-qZ3gB14ojTjd50cU2lwB5bT8uwdJ1wVfnRysmxfG68E=";
    };
  };
  souffle-treesitter-grammar = pkgs.tree-sitter.buildGrammar {
    language = "souffle";
    version = "901e7136";
    src = tree-sitter-souffle-langston-barrett;
  };
  my-souffle-treesitter-grammar-src = pkgs.fetchFromGitHub {
    owner = "dbueno";
    repo = "tree-sitter-souffle";
    rev = "f088865188e78cfdaf19581d890c94d79db8054b";
    hash = "sha256-J9yH0dJYNDSmuA23vkz2WLWNhk80g8FqwgGp9qrmnzc=";
  };
  my-souffle-treesitter-grammar = pkgs.tree-sitter.buildGrammar {
    language = "souffle";
    version = "improve-preprocessor";
    src = my-souffle-treesitter-grammar-src;
  };
  meh = pkgs.vimUtils.buildVimPlugin rec {
    pname = "vim-colors-meh";
    version = "e2962284bbd53db5cbe2db39efaa3ea74ade0fb1";
    src = pkgs.fetchFromGitHub {
      owner = "davidosomething";
      repo = "${pname}";
      rev = "${version}";
      hash = "sha256-SRYWawm2WMGihwhicvqeubDE96+4JEUXIP5dpxzYVa4=";
    };
  };
in {

  nixpkgs.overlays = [
    (import ./overlays/witchhazel.nix)
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = true;
    extraPackages = with pkgs; [
      clang-tools
      clang
      nodePackages.pyright
    ];
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      witchhazel-vim
      meh
      my-vim-tweaks
      my-neovim-tweaks
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
      (nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars ++ [
        my-souffle-treesitter-grammar
      ]))
      nvim-treesitter-textobjects

      cmp-vsnip
      vim-vsnip

      vim-rooter
      fzf-vim
    ];
    extraConfig = builtins.readFile ./config/nvim/vimrc
    + ''

      set hidden
      set smartcase
      set ignorecase
      set modeline
      set number
      set expandtab
      set shiftwidth=2
      set completeopt=menuone,noinsert,noselect

      set cmdheight=2

      set updatetime=300

      autocmd BufNewFile,BufRead *.dl setfiletype souffle

      " lighten up dracula comments
      augroup my_colorschemes
        au!
        au Colorscheme dracula hi Comment guifg=#7c8ca8 ctermfg=69
      augroup END

      colorscheme tokyonight
    '';
    extraLuaConfig = builtins.readFile ./config/nvim/init.lua;

  };
}
