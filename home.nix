{ config, pkgs, ... }:

let
  myInfo = pkgs.lib.importJSON ./userconfig.json;
  nixFlakes =
    (pkgs.writeShellScriptBin "nixFlakes" ''
        exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '');

  completeAlias = pkgs.stdenv.mkDerivation {
    name = "complete-alias";
    src = pkgs.fetchFromGitHub {
      owner = "cykerway";
      repo = "complete-alias";
      rev = "b16b183f6bf0029b9714b0e0178b6bd28eda52f3";
      sha256 = "1a3szf0bvj0mk2kcq1052q9xzjqiwgmavfg348dspfz543nigvk2";
    };
    installPhase = ''
      mkdir -p $out
      cp complete_alias $out/
    '';
  };

  rusage = (import (builtins.fetchTarball "https://github.com/dbueno/rusage/archive/main.tar.gz")).defaultPackage.${pkgs.system};

  # ASCII graphs from graphviz input
  GraphEasy = pkgs.buildPerlPackage {
    pname = "Graph-Easy";
    version = "0.76";
    src = pkgs.fetchurl {
      url = "mirror://cpan/authors/id/S/SH/SHLOMIF/Graph-Easy-0.76.tar.gz";
      sha256 = "d4a2c10aebef663b598ea37f3aa3e3b752acf1fbbb961232c3dbe1155008d1fa";
    };
    buildInputs = [ pkgs.makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/graph-easy --set PERL5LIB ${pkgs.perlPackages.makeFullPerlPath []}
    '';
    meta = {
      description = "Convert or render graphs (as ASCII, HTML, SVG or via Graphviz)";
      license = pkgs.lib.licenses.gpl1Plus;
    };
  };

  myVimPlugins =
    let
      my-vim-tweaks = pkgs.vimUtils.buildVimPlugin {
        name = "denisbueno-vim-tweaks.vim";
        src = ./dotvim;
      };
      vim-souffle = pkgs.vimUtils.buildVimPlugin {
        name = "souffle.vim";
        src = pkgs.fetchFromGitHub {
          owner = "souffle-lang";
          repo = "souffle.vim";
          rev = "1402e6905e085bf04faf5fca36a6fddba01119d6";
          sha256 = "1y779fi2vfaca5c2285l7yn2cmj2sv8kzj9w00v9hsh1894kj2i4";
        };
      };
      vim-qfgrep = pkgs.vimUtils.buildVimPlugin {
        name = "QFGrep.vim";
        src = pkgs.fetchFromGitHub {
          owner = "dbueno";
          repo = "QFGrep";
          rev = "filter-contents";
          sha256 = "0jz8q0k839rw3dgb1c9ff8zlsir9qypicicxm8vw23ynmjk2zziy";
        };
      };
      vim-riv = pkgs.vimUtils.buildVimPlugin {
        name = "riv.vim";
        src = pkgs.fetchFromGitHub {
          owner = "gu-fan";
          repo = "riv.vim";
          rev = "201ffc4e8dbfc3deeb26c6e278980f53d81d7f6a";
          sha256 = "1drl291lq44hf7qx1g6l5ivqclfb6ih9lj5qy5cmv9w9b3svwlv4";
        };
      };
      vim-euforia = pkgs.vimUtils.buildVimPlugin {
        name = "euforia.vim";
        src = builtins.fetchGit {
          url = "git@github.com:greedy/vim-euforia.git";
          ref = "master";
          rev = "96ee4c9c7296dbb75f7e927e93e4576dec1c898e";
        };
      };
    in [
      my-vim-tweaks
      vim-souffle
      vim-euforia
      vim-qfgrep
      #vim-riv
    ];

  # extra config for plugins
  myVimPluginsConfig = ''
    " riv wants to use large patterns
    set maxmempattern=2000
  '';

  myScripts =
    let
      onChange = pkgs.writeShellScriptBin "onchange" ''
        # TODO: Add option to watch a directory other than the current directory.

        msg="usage: onchange.sh command [arg ...]
        Arguments should be what you want to run when anything on the filesystem
        changes (relative to current directory)."
        if [ -z "$1" ]; then
            printf "%s\n" "$msg"
            exit 1
        fi

        # Runs command up front because usually this is what I want.
        ( "$@" ) # || exit 1

        while true; do
            # fswatch returns exit code 0 regardless. If a file changes fswatch -1 will
            # print its name. Sets n to 1 if that happens.
            n=$(${pkgs.fswatch}/bin/fswatch -1 . | wc -l | tr -d ' \t')
            if [[ $n -gt 0 ]]; then
                ( "$@" ) # || exit 1
            else
                exit 0
            fi
        done
      '';
      google = pkgs.writeShellScriptBin "google" ''
        ${pkgs.lynx}/bin/lynx http://www.google.com/search?q="$@"
      '';
    in [
      onChange
      google
      (pkgs.writeShellScriptBin "ifnewer" (builtins.readFile ./ifnewer.sh))
      (pkgs.writeShellScriptBin "wtf" (builtins.readFile ./wtf.sh))
      (pkgs.writeShellScriptBin "sync-my-repos" (builtins.readFile ./sync-my-repos.sh))
      (pkgs.writeShellScriptBin "frequency" (builtins.readFile ./automation/frequency.sh))
    ];
in

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = myInfo.username;
  home.homeDirectory = myInfo.homeDirectory;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  programs.man.enable = true;

  programs.bat = {
    enable = true;
  };

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = ''rg --iglob "!/_opam" --iglob "!/_build" --iglob "!*.o" --files --hidden'';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.enableFlakes = true;
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = myInfo.name;
    userEmail = myInfo.email;
    ignores = [
      # vim
      "*.swp" "*.swo"
      # direnv
      "/.direnv/" "/.envrc"
      # files I make to store things
      "*.out"
    ];
    lfs = { enable = true; };

    aliases = {
      a = "add -p";
      d = "diff";
      di = "diff --cached";
      dt = "difftool";
      pa = "push --all";
      co = "checkout";
      ci = "commit";
      s = let
        # Prints status without untracked files
        cmd = pkgs.writeShellScriptBin "my-git-status" ''
          git status -uno || exit 0
          # Prints only a count summary of untracked files
          git status --short | \
              awk '/[?][?]/ { c += 1 } END { if (c > 0) { printf("\n... and %s untracked files\n", c) } }' || exit 0
          '';
        in
        "!${cmd}/bin/my-git-status";
      ss = "status";
      # print git directory, toplevel of current repo
      pgd = "git rev-parse --show-toplevel";
      push-it-real-good = "push -f";
      b = "branch";
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      f = "fetch";
    };

    extraConfig = {
      init = { defaultBranch = "main"; };
      core = {
        fsyncobjectfiles = "true";
        sshCommand = "${pkgs.openssh}/bin/ssh -F ~/.ssh/config";
      };
      push = { default = "simple"; };
      pull = { rebase = "true"; };
      color = {
        interactive = "auto";
        diff = "auto";
      };
    };
  };

  programs.htop = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "SF Mono Medium";
      font_size = "13.0";
      enabled_layouts = "tall:bias=50;full_size=1;mirrored=false,fat,stack";
      confirm_os_window_close = 1;
    };
    keybindings = {
      "ctrl+p" = "scroll_page_up";
      "ctrl+n" = "scroll_page_down";
    };
    extraConfig = builtins.readFile ./kitty-nord-theme.conf;
  };

  programs.readline = {
    enable = true;
    variables = {
      bell-style = "visible";
      # Immediately show all TAB-completions -- don't require two TABs.
      # show-all-if-ambiguous = true;
      # Show status of completed filenames, like ls -F does.
      visible-stats = true;
      completion-ignore-case = true;
    };
  };

  programs.bash = {
    enable = true;
    historySize = 1000000;
    # The & removes dups; [ ]* ignores commands prefixed with spaces.  Other
    # commands, like job control and ls'ing are also ignored.
    historyIgnore = [ "\"&\"" "\"[ ]*\"" "exit" "pwd" "\"[bf]g\"" "no" "lo" "lt" "pd" "c" "a" "aa" "s" "ss" "\"g a\"" "\"g s\"" "\"g ss\"" "reset" ];

    shellOptions = [
      # Correct transpositions and other minor details from 'cd DIR' command.
      "cdspell"
      # Include hidden files in glob (*).
      "dotglob"
      # Extra-special pattern matching in the shell.
      "extglob"
      # Flatten multiple-line commands into the same history entry.
      "cmdhist"
      # Don't complete when I haven't typed anything.
      "no_empty_cmd_completion"
      # Let me know if I shift stupidly.
      "shift_verbose"
      # With this, cd $HOME/<TAB> expands the variable instead of escaping it.
      # Ideally, bash would just leave it alone.
      "direxpand"
    ];

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      EDITOR = "vim";
      ED = "vim";
      # For Linux, pretty colors.
      # LS_COLORS = "di=00;36;40:ln=00;35:ex=00;31";
      # For mac, pretty colors. -- but see also dircolors above
      LSCOLORS = "gxfxcxdxbxegedabagacad";
      # When I type 'cd somewhere', if somewhere is relative, try out looking into all
      # the paths in $CDPATH for completions.  This can speed up common directory
      # switching.
      #
      # The . is here so that if I type cd <dir> it goes to curdir first
      CDPATH = ".:~/work/inprogress";
    };

    shellAliases =
      (if pkgs.stdenv.isDarwin then {
        a = let
            cmd = pkgs.writeShellScriptBin "my-ls" ''
              num_files=$(ls -1 "$@" 2>/dev/null | wc -l | sed 's/[[:space:]]//g')
              cutoff=20
              if [ $num_files -gt $cutoff ]; then
                CLICOLOR_FORCE=1 ls -lFGtrh "$@" | tail -n $cutoff
                printf "[showing 20 of %d files]\n" $num_files
              else
                CLICOLOR_FORCE=1 ls -lFGtrh "$@"
              fi
            '';
          in
          "${cmd}/bin/my-ls";
        aa="ls -lFGtrh";
        mk="make -j$(sysctl -a | grep ^hw[.]ncpu | cut -d' ' -f2)";
        lldb="PATH=/usr/bin:$PATH lldb";
      } else {
        a = let
            cmd = pkgs.writeShellScriptBin "my-ls" ''
              num_files=$(ls -1 "$@" 2>/dev/null | wc -l | sed 's/[[:space:]]//g')
              cutoff=20
              if [ $num_files -gt $cutoff ]; then
                ls -lF --color -trh "$@" | tail -n $cutoff
                printf "[showing 20 of %d files]\n" $num_files
              else
                ls -lF --color -trh "$@"
              fi
            '';
          in
          "${cmd}/bin/my-ls";
        aa="ls -lF --color -trh";
      })
    // {
      hmsw = "home-manager switch";
      # there's always a story behind aliases like these
      rm = "rm -i";
      c = "clear";
      pd = "cd \"$OLDPWD\"";
      # Evaluates to an iso-conformant date.  The iso-conformance is good because
      # lexicographic order coincides with date order.  'nows' just has seconds and
      # is also iso-conformant.
      now = "date '+%Y-%m-%dT%H%M'";
      nows = "date '+%Y-%m-%dT%H%M%S'";
      today = "date '+%Y-%m-%d'";

      average = "${pkgs.R}/bin/Rscript -e 'd<-scan(\"stdin\", quiet=TRUE)' -e 'summary(d)'";

      # Displays an image (png) in the terminal
      icat = "kitty +kitten icat --align=left";
      # Displays an SVG in the terminal
      isvg = "${pkgs.librsvg}/bin/rsvg-convert | icat";
      # Displays a DOT graph in the terminal
      # see ratio="compress" or unflatten | idot
      idot = ''${pkgs.graphviz}/bin/dot -Gbgcolor=transparent -Nfontcolor=#2E3440 -Nstyle=filled \
        -Nfillcolor=#D8DEE9 -Ecolor=#5E81AC -Efontcolor=#8FBCBB -Nfontname=Helvetica -Efontname=Helvetica \
        -Nfontsize=11 -Efontsize=10 -Gratio=compress -Tsvg | isvg'';
      # XXX where is hb-view
      hb-feat =
        let cmd = pkgs.writeShellScriptBin "hb-feat" ''
          # from @thingskatedid
          # otfinfo --features <file.otf> to see features
          # Default color is black so the sed changes it to whitish (nord palette).
          ${pkgs.harfbuzz}/bin/hb-view --features="$2" -O svg "$1" "$3" | \
              grep -v '<rect' | \
              sed 's/<g style="fill:rgb(0%,0%,0%);fill-opacity:1;">/<g style="fill:#ECEFF4">/' | \
              ${pkgs.librsvg}/bin/rsvg-convert | \
              ${pkgs.imagemagick}/bin/convert -trim -resize '25%' - - | \
              kitty +kitten icat --align=left
              '';
        in
        "${cmd}/bin/hb-feat";

      g = "git";

      # Greps and displays with less, with colors
      lrg = ''rg --line-buffered --pretty "$@" | less -R'';
      # Greps and fuzzy selects
      frg = ''rg "$@" | fzf'';
      ssh = let
        cmd = pkgs.writeShellScriptBin "my-ssh" ''
          if [[ "$TERM" = *kitty ]]; then
              env TERM=xterm-256color ssh "$@"
          else
              env ssh "$@"
          fi
          '';
      in
        "${cmd}/bin/my-ssh";

      make_cpptags = "${pkgs.universal-ctags}/bin/ctags --c++-kinds=+pf --c-kinds=+p --fields=+imaSft --extra=+q -Rnu";

      record-my-session = ''
        test -z "$SCRIPT" && script -a $HOME/.terminal-logs/script.$$.$(date '+%Y-%m-%dT%H%M')
      '';
    };

    # Settings for interactive shells
    # .bashrc is executed for interactive non-login shells
    bashrcExtra = builtins.readFile ./bashrc_extra
      + builtins.readFile ./.bash_completion
      + ''
        . ${completeAlias}/complete_alias
        complete -F _complete_alias g
        complete -F _complete_alias rm
        complete -F _complete_alias aa
        complete -F _complete_alias ss

        test -d $HOME/.terminal-logs || mkdir $HOME/.terminal-logs
        if test -z "$SCRIPT"; then
          if test -t 0; then
            script -a $HOME/.terminal-logs/script.$$.out
          fi
        fi
      '';

    profileExtra = ''
      [[ -e "$HOME/.bash_profile_local" ]] && source "$HOME/.bash_profile_local"
      history -a
    '';
  };

  home.file = {
    ".tmux-linux".source = ./.tmux-linux;
    ".hammerspoon/init.lua".source = ./hammerspoon.lua;
    ".gdbinit".source = ./.gdbinit;
    ".ghci".source = ./.ghci;
    ".lynxrc".source = ./.lynxrc;
    ".config/automate-everything/repos".source = ./repos.conf;
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./.tmux.conf;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = { identitiesOnly = true; };
      "denisbueno.net" = { user = "dbueno"; };
    }
    // (import ./ssh_extra_blocks.nix);
  };

  programs.vim = {
    enable = true;
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
      nord-vim
      vim-ocaml
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
    ]
    ++ myVimPlugins;
    extraConfig = builtins.readFile ./vimrc_extra
    + ''

      ${myVimPluginsConfig}
    '';
  };

  home.packages = with pkgs; [
    bashInteractive_5
    ripgrep
    bash-completion nix-bash-completions
    graphviz
    wget
    parallel
    nixFlakes
    duc # ncdu replacement
    zip unzip p7zip
    bat-extras.batdiff
    colordiff
    wdiff
    rusage
    GraphEasy
  ]
  ++ myScripts;
}
