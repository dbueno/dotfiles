{ config, lib, pkgs, ... }:
let
  vim-plugins =
    let
      my-vim-tweaks = pkgs.vimUtils.buildVimPlugin {
        pname = "denisbueno-vim-tweaks.vim";
        version = "dev";
        src = ./dotvim;
      };
      vim-souffle = pkgs.vimUtils.buildVimPlugin rec {
        pname = "souffle.vim";
        version = "1402e6905e085bf04faf5fca36a6fddba01119d6";
        src = pkgs.fetchFromGitHub {
          owner = "souffle-lang";
          repo = "souffle.vim";
          rev = "${version}";
          sha256 = "1y779fi2vfaca5c2285l7yn2cmj2sv8kzj9w00v9hsh1894kj2i4";
        };
        patches = [ ./pkgs/souffle-vim/souffle-vim.patch ];
      };
      vim-qfgrep = pkgs.vimUtils.buildVimPlugin rec {
        pname = "QFGrep.vim";
        version = "filter-contents";
        src = pkgs.fetchFromGitHub {
          owner = "dbueno";
          repo = "QFGrep";
          rev = "${version}";
          sha256 = "0jz8q0k839rw3dgb1c9ff8zlsir9qypicicxm8vw23ynmjk2zziy";
        };
      };
      vim-shimple = pkgs.vimUtils.buildVimPlugin rec {
        pname = "shimple.vim";
        version = "1f652298569081579a773ed629fa7bde2ae7f115";
        src = pkgs.fetchFromGitHub {
          owner = "dbueno";
          repo = "vim-shimple";
          rev = "${version}";
          sha256 = "mFZf59RoIMfGW/EbsEbdsVrYzJjOrOgA4oo3AsprZhc=";
        };
      };
      vim-voom = pkgs.vimUtils.buildVimPlugin rec {
        pname = "vim-voom";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "${pname}";
          repo = "VOoM";
          rev = "${version}";
          sha256 = "sha256-urmOP3BiavTPDaNlvc0Y/oIQLLe5AKhZZAWom8DK+J4=";
        };
      };
      vim-textobj-sentence = pkgs.vimUtils.buildVimPlugin rec {
        pname = "vim-textobj-sentence";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "preservim";
          repo = "${pname}";
          rev = "${version}";
          sha256 = "sha256-T8Uyxtf0ETOI9oonGbo0gSuwSpu6DxydKpR+jwzDhno=";
        };
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
      programs.vim.plugins = [
        my-vim-tweaks
        vim-souffle
        vim-shimple
        vim-qfgrep
        vim-voom
        vim-textobj-sentence
        my-vimoutliner
      ];
    };
in {
  imports = [ vim-plugins ];

  programs.vim = {
    enable = false;
    defaultEditor = true;
    settings = {
      # keep buffers around when they are not visible
      hidden = true;
      # ignore case except mixed lower and uppercase in patterns
      smartcase = true;
      ignorecase = true;
      modeline = true;
      mouse = "a";
      number = true;
      expandtab = true;
      # default shiftwidth to 4
      shiftwidth = 4;
    };
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      fzf-vim
      vim-fugitive
      vim-surround
      vim-vinegar
      vim-unimpaired
      verilog_systemverilog-vim
      vimtex
      vim-nix
      vim-pathogen
      vim-commentary
      vim-repeat
      tabular
      goyo-vim
      limelight-vim
      vim-textobj-user
      vim-markdown
    ];
    extraConfig = builtins.readFile ./config/vimrc
    + lib.optionalString pkgs.stdenv.isDarwin ''
      let g:fzf_preview_window = ['right:50%,~5', 'ctrl-/']
    '';
  };
}
