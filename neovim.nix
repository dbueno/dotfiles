{
  config,
  lib,
  pkgs,
  ...
}:
let
  my-vim-tweaks = pkgs.vimUtils.buildVimPlugin {
    pname = "denisbueno-vim-config.vim";
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
  synthwave84-nvim = pkgs.vimUtils.buildVimPlugin rec {
    pname = "synthwave84";
    version = "a5caa80d9e1a7021f9ec6c06a96d09dfc2d99ed1";
    src = pkgs.fetchFromGitHub {
      "owner" = "artanikin";
      "repo" = "vim-synthwave84";
      "rev" = "a5caa80d9e1a7021f9ec6c06a96d09dfc2d99ed1";
      "hash" = "sha256-5+rOp2xDdtIMxMdvV0N18yTSQuSzYIfnFvwNeufaDgQ=";
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
  nvim-jdtls = pkgs.vimUtils.buildVimPlugin rec {
    pname = "nvim-jdtls";
    version = "efe813854432a314b472226dca813f0f2598d44a";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "${pname}";
      rev = "${version}";
      hash = "sha256-r9qbunFJ62IqibVAdGbLsWSwYL53YKElLy98ArsK5V8=";
    };
  };
in
{
  nixpkgs.overlays = [
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = true;
    plugins =
      [
        synthwave84-nvim
        nvim-jdtls
      ]
      ++ (with pkgs.vimPlugins; [
        tokyonight-nvim
        my-vim-tweaks
        my-neovim-tweaks
        my-vimoutliner
        vim-fugitive
        vim-nix
        vim-commentary
        #tabular
        vim-surround
        securemodelines
        editorconfig-vim

        plenary-nvim

        nvim-lspconfig
        lsp_extensions-nvim
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        nvim-cmp
        lsp_signature-nvim
        (nvim-treesitter.withPlugins (
          _:
          nvim-treesitter.allGrammars
          ++ [
            my-souffle-treesitter-grammar
          ]
        ))
        nvim-treesitter-textobjects

        cmp-vsnip
        vim-vsnip

        fzf-vim
      ]);
    extraConfig =
      builtins.readFile ./config/nvim/vimrc
      + ''

        set hidden
        set smartcase
        set ignorecase
        set modeline
        set number
        set expandtab
        set shiftwidth=2
        set completeopt=menuone,noinsert,noselect

        autocmd BufNewFile,BufRead *.dl setfiletype souffle

        " lighten up theme comments
        augroup my_colorschemes
          au!
          au Colorscheme dracula hi Comment guifg=#7c8ca8 ctermfg=69
          au Colorscheme synthwave84 hi Comment guifg=#7c8ca8 ctermfg=69
          au Colorscheme tokyonight-night hi Comment guifg=#7c8ca8 ctermfg=69
          au Colorscheme tokyonight-night hi Search guibg=#1a1b26 guifg=#FBEC5D gui=underline
          au Colorscheme tokyonight-night hi IncSearch guibg=#1a1b26 guifg=#FBEC5D gui=underline
          au Colorscheme slate hi Comment ctermfg=188
        augroup END
        set notermguicolors
        colorscheme slate
        "colorscheme tokyonight-night
      '';
    extraLuaConfig = builtins.readFile ./config/nvim/init.lua;
  };
}
