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

  home.packages = with pkgs; [
    nodePackages.pyright
  ];

  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = true;
    extraPackages = with pkgs; [
      clang-tools
      clang
    ];
    plugins = with pkgs.vimPlugins; [
      meh
      my-vim-tweaks
      #my-neovim-tweaks
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
        souffle-treesitter-grammar
      ]))

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

      autocmd BufNewFile,BufRead *.dl setfiletype souffle

      colorscheme meh


    '';
    extraLuaConfig = ''

      require'nvim-treesitter.configs'.setup {
        highlight = {
          enable = true,              -- false will disable the whole extension
          disable = { "rust" },  -- list of language that will be disabled
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }

      require'lspconfig'.pyright.setup{}
    '';
  };
}
