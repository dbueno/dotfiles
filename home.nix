{ config, pkgs, ... }:

let
  myName = "Denis Bueno";
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
  home.username = "denbuen";
  home.homeDirectory = "/Users/denbuen";

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
    userName = myName;
    userEmail = "dbueno" + "@" + "gmail.com";
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

  programs.nix-index = {
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
    historyIgnore = [ "\"&\"" "\"[ ]*\"" "exit" "pwd" "\"[bf]g\"" "no" "lo" "lt" "pd" "c" "a" "aa" "s" "ss" ];

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
    ".config/automate-everything/repos".source = ./automate-everything-repos.conf;
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

  #Example of vim plugin from git
    # context-vim = pkgs.vimUtils.buildVimPlugin {
    #   name = "context-vim";
    #   src = pkgs.fetchFromGitHub {
    #   owner = "wellle";
    #   repo = "context.vim";
    #   rev = "e38496f1eb5bb52b1022e5c1f694e9be61c3714c";
    #   sha256 = "1iy614py9qz4rwk9p4pr1ci0m1lvxil0xiv3ymqzhqrw5l55n346";
    #   };
    #   };

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
    ];
    extraConfig = builtins.readFile ./vimrc_extra;
  };

  home.packages = with pkgs; [
    bashInteractive_5
    ripgrep
    bash-completion nix-bash-completions
    graphviz
    wget
    parallel
    nixFlakes
    ncdu
    zip unzip p7zip
  ]
  ++ myScripts;
}
