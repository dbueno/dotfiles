{ config, lib, pkgs, rusage, ... }:
let
  draculaTheme = rec {
    Background = "#282A36";
    Foreground = "#F8F8F2";
    Selection = "#44475A";
    Comment = "#6272A4";
    Red = "#FF5555";
    Orange = "#FFB86C";
    Yellow = "#F1FA8C";
    Green = "#50FA7B";
    Purple = "#BD93F9";
    Cyan = "#8BE9FD";
    Pink = "#FF79C6";
    AnsiBlack = "#21222C";
    AnsiRed = "#FF5555";
    AnsiGreen = "#50FA7B";
    AnsiYellow = "#F1FA8C";
    AnsiBlue = "#BD93F9";
    AnsiMagenta = "#FF79C6";
    AnsiCyan = "#8BE9FD";
    AnsiWhite = "#F8F8F2";
    AnsiBrightBlack = "#6272A4";
    AnsiBrightRed = "#FF6E6E";
    AnsiBrightGreen = "#69FF94";
    AnsiBrightYellow = "#FFFFA5";
    AnsiBrightBlue = "#D6ACFF";
    AnsiBrightMagenta = "#FF92DF";
    AnsiBrightCyan = "#A4FFFF";
    AnsiBrightWhite = "#FFFFFF";
    DiffText = Comment;
    DiffHeader = Comment;
    DiffInserted = Green;
    DiffDeleted = Red;
    DiffChanged = Orange;
  };

  onetrueawk = { stdenv, bison, yacc }: stdenv.mkDerivation rec {
    pname = "onetrueawk";
    version = "20210724";
    src = pkgs.fetchFromGitHub {
      owner = "${pname}";
      repo = "awk";
      rev = "f9affa922c5e074990a999d486d4bc823590fd93";
      sha256 = "06590dqql0pg3fdqpssh7ca1d02kzswddrxwa8xd59c15vsz9r42";
    };
    patchPhase = '' substituteInPlace makefile --replace 'gcc' 'cc' '';
    nativeBuildInputs = [ bison yacc ];
    installPhase = ''
      mkdir -p $out/bin
      cp a.out $out/bin/onetrueawk
    '';
  };

  sponge = pkgs.writeShellScriptBin "sponge" ''
    # Just calls moreutils sponge
    ${pkgs.moreutils}/bin/sponge "$@"
  '';

  completeAlias = pkgs.stdenv.mkDerivation {
    pname = "complete-alias";
    version = "dev";
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

  # ASCII graphs from graphviz input
  GraphEasy = pkgs.perlPackages.buildPerlPackage {
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
      license = lib.licenses.gpl1Plus;
    };
  };

  # Filters all zettel notes, then print the contents of each zettel, for a
  # subsequent fzf.vim search.
  ztl_filter = pkgs.writeShellScriptBin "ztl_filter" ''
    rg -l -0 '#ztl' | xargs -0 rg --column --line-number --no-heading --color=always --smart-case -- '^|#ztl'
  '';

  ztl_tagcloud = pkgs.writeShellScriptBin "ztl_tagcloud" ''
    rg --no-column --no-line-number -I -o -w '#[a-zA-Z_-]\w*' | sort | uniq
  '';

  bunch = pkgs.writeShellScriptBin "bunch" ''
    # Bunches stdin lines into groups in multiple output files. Each new output
    # file is based on a trigger, which is just some text (not a regex,
    # currently). Every time a line matches the trigger a new output file is
    # created and subsequent input is echoed to that output file.

    usage() { echo  "Usage: $0 [-d dir] trigger extension" 1>&2; exit 1; }

    dir=""
    while getopts d: flag
    do
        case "''${flag}" in
            d) dir=''${OPTARG};;
            *) usage;
        esac
    done
    shift $((OPTIND-1))

    trigger="$1"
    ext="$2"

    if test -z "$trigger" || test -z "$ext"; then
        usage
    fi
    #echo $trigger $ext $dir
    i=0
    test -n "$dir" && cd "$dir"
    exec &> $i.$ext
    while read; do
        if [[ "$REPLY" == *$trigger* ]]; then
            i=$((i+1))
            exec &> $i.$ext
        fi
        echo $REPLY
    done
  '';

  record-my-session = pkgs.writeShellScriptBin "record-my-session" ''
    # Keeps a record of terminal input and output inside .terminal-logs by
    # default.
    mkdir -p $HOME/.terminal-logs
    # Tests for infinite recursion (SCRIPT is set by script).
    if test -z "$SCRIPT"; then
      if test -t 0; then
        script -a $HOME/.terminal-logs/script.$$.out && exit
      fi
    fi
  '';

  ssh-script = pkgs.writeShellScriptBin "my-ssh" ''
    if [[ "$TERM" = *kitty ]]; then
        env TERM=xterm-256color ssh "$@"
    else
        env ssh "$@"
    fi
    '';
  ssh-cmd = "${ssh-script}/bin/my-ssh";
  ssh-with-env-pass = pkgs.writeShellScriptBin "ssh-with-env-pass" ''
    # You could add a function like this in your environment:
    # function ssh-to-host() {
    #   SSHPASS=$(cat ~/.host-password) ssh-with-env-pass host
    # }
    ${pkgs.sshpass}/bin/sshpass -e ${ssh-cmd} "$@"
  '';
  rsync-with-env-pass = pkgs.writeShellScriptBin "rsync-with-env-pass" ''
    rsync --rsh='${pkgs.sshpass}/bin/sshpass -e ssh' "$@"
  '';

  pythonWithNumpy = pkgs.python3.withPackages (p: with p; [
    pandas numpy scipy ]);

  myVimPlugins =
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
        patches = [ ./souffle-vim.patch ];
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
      vim-riv = pkgs.vimUtils.buildVimPlugin rec {
        pname = "riv.vim";
        version = "201ffc4e8dbfc3deeb26c6e278980f53d81d7f6a";
        src = pkgs.fetchFromGitHub {
          owner = "gu-fan";
          repo = "riv.vim";
          rev = "${version}";
          sha256 = "1drl291lq44hf7qx1g6l5ivqclfb6ih9lj5qy5cmv9w9b3svwlv4";
        };
      };
      vim-euforia = pkgs.vimUtils.buildVimPlugin rec {
        pname = "euforia.vim";
        version = "master";
        src = builtins.fetchGit {
          url = "ssh://git@github.com/greedy/vim-euforia.git";
          rev = "96ee4c9c7296dbb75f7e927e93e4576dec1c898e";
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
    in [
      my-vim-tweaks
      vim-souffle
      vim-euforia
      vim-qfgrep
      vim-voom
      vim-textobj-sentence
      #vim-riv
    ];

  # extra config for plugins
  myVimPluginsConfig = ''
    " riv wants to use large patterns
    set maxmempattern=2000
  ''
  + lib.optionalString pkgs.stdenv.isDarwin ''
    let g:fzf_preview_window = ['right:50%,~5', 'ctrl-/']
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
        ${pkgs.w3m}/bin/w3m http://www.google.com/search?q="$@"
      '';
      uncolor = pkgs.writeShellScriptBin "uncolor" ''
        while getopts ":h" opt; do
          case $opt in
              h)
                echo "Removes escaped colors from text intended for a terminal"
                echo "Usage: uncolor <file>"
                exit 0
                ;;
          esac
        done

        ${pkgs.gnused}/bin/sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' "$@"
      '';
      viewhex = pkgs.writeShellScriptBin "viewhex" ''${pkgs.hexyl}/bin/hexyl "$@"'';
      viewjson = pkgs.writeShellScriptBin "viewjson" ''${pkgs.fx}/bin/fx "$@"'';
    in [
      onChange
      google
      uncolor
      ssh-with-env-pass
      rsync-with-env-pass
      viewjson
      viewhex
      (pkgs.writeShellScriptBin "ifnewer" (builtins.readFile ./ifnewer.sh))
      (pkgs.writeShellScriptBin "wtf" (builtins.readFile ./wtf.sh))
      (pkgs.writeShellScriptBin "sync-my-repos" (builtins.readFile ./sync-my-repos.sh))
      (pkgs.writeShellScriptBin "frequency" (builtins.readFile ./automation/frequency.sh))
    ];
in
{
  nixpkgs.overlays = [
    (import ./overlays/diff-so-fancy.nix)
    (import ./overlays/YouCompleteMe.nix)
  ];

  nixpkgs.config.allowUnfree = true;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.man.enable = true;

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
    themes = {
      dracula = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "sublime"; # Bat uses sublime syntax for its themes
        rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
        sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
        } + "/Dracula.tmTheme");
      };
  };

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
    settings = (import ./kitty-themes/dracula/dircolors.nix);
  };

  programs.fzf = {
    enable = true;
    defaultCommand = ''rg --iglob "!/_opam" --iglob "!/_build" --iglob "!*.o" --files --hidden'';
    defaultOptions = [
      # https://draculatheme.com/fzf
      "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
      "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
      "--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6"
      "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    package = pkgs.gitFull;
    enable = true;
    userName = "Denis Bueno";
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
      dt = "difftool --no-symlinks --dir-diff";
      pa = "push --all";
      co = "checkout";
      ci = "commit";
      sw = "switch";
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
      push-it-real-good = "push --force-with-lease";
      b = "branch";
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      f = "fetch";
    };

    extraConfig = {
      init = { defaultBranch = "main"; };
      core = {
        sshCommand = "${pkgs.openssh}/bin/ssh -F ~/.ssh/config";
        pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy | less --tabs=4 -RFX";
      };
      diff = {
        tool = "kitty";
        guitool = "kitty.gui";
      };
      # Works around what is apparently a git bug in parsing diff-so-fancy's
      # ansi directives. This reverts git to an older interactive diff engine
      # that doesn't have this parsing problem.
      add.interactive.useBuiltin = false;
      interactive.diffFilter = "${pkgs.diff-so-fancy}/bin/diff-so-fancy --patch";
      difftool = {
        prompt = false;
        trustExitCode = true;
        kitty = {
          cmd = "kitty +kitten diff $LOCAL $REMOTE";
        };
        "kitty.gui" = {
          cmd = "kitty kitty +kitten diff $LOCAL $REMOTE";
        };
        vim = {
          cmd = "vimdiff $LOCAL $REMOTE";
        };
      };
      push = { default = "simple"; };
      pull = { rebase = "true"; };
      color = {
        interactive = "auto";
        # diff = "auto";
        diff = with draculaTheme; {
          context = Foreground;
          meta = Comment;
          frag = DiffHeader;
          func = "${Green}";
          commit = "${Yellow} bold";
          old = DiffDeleted;
          oldMoved = DiffDeleted;
          new = DiffInserted;
          newMoved = DiffInserted;
          whitespace = DiffDeleted;
        };
      };
    };
  };

  programs.htop = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      enabled_layouts = lib.concatStringsSep "," [
        "tall:bias=50;full_size=1;mirrored=false"
        "horizontal" "vertical" "fat" "stack"
      ];
      shell = "${pkgs.bashInteractive}/bin/bash --login -i";
      confirm_os_window_close = 1;
      scrollback_pager_history_size = 10000;
      scrollback_fill_enlarged_window = true;
      macos_thicken_font = "0.5";
    };
    keybindings = {
      "ctrl+p" = "scroll_page_up";
      "ctrl+n" = "scroll_page_down";
      "kitty_mod+h" = "previous_window";
      "kitty_mod+l" = "next_window";
      # kitty-mod+l defaults to next_layout so put the layout
      # commands on brackets.
      "kitty_mod+]" = "next_layout";
      "f12" = "show_scrollback";
      "f11" = "toggle_layout stack";
      "f10" = "show_last_command_output";
      "f1" = "create_marker";
      "f2" = "remove_marker";
      "ctrl+0" = "scroll_to_mark next";
      "ctrl+9" = "scroll_to_mark prev";
      "ctrl+[" = "layout_action decrease_num_full_size_windows";
      "ctrl+]" = "layout_action increase_num_full_size_windows";
    };
    # extraConfig = builtins.readFile ./kitty-themes/nord/nord.conf;
    extraConfig = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "kitty";
      rev = "eeaa86a730e3d38649053574dc60a74ce06a01bc";
      sha256 = "3yi5e/wnLYt7b3Lkf4fhSByr18SrOzJ4zYympUQMslc=";
    } + "/dracula.conf");
  };

  xdg = {
    enable = true;
    configFile."kitty/diff.conf".source = (pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "kitty";
      rev = "eeaa86a730e3d38649053574dc60a74ce06a01bc";
      sha256 = "3yi5e/wnLYt7b3Lkf4fhSByr18SrOzJ4zYympUQMslc=";
    } + "/diff.conf");
    configFile."mutt/muttrc".source = ./.muttrc;
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
      # LSCOLORS = "gxfxcxdxbxegedabagacad";
      # When I type 'cd somewhere', if somewhere is relative, try out looking into all
      # the paths in $CDPATH for completions.  This can speed up common directory
      # switching.
      #
      # The . is here so that if I type cd <dir> it goes to curdir first
      CDPATH = ".:~/work/inprogress";
    };

    shellAliases =
      let
        ls-command = if pkgs.stdenv.isDarwin then "CLICOLOR_FORCE=1 ls -lFGth" else "ls -lF --color -th";
      in
      (if pkgs.stdenv.isDarwin then { lldb = "PATH=/usr/bin:$PATH lldb"; } else {})
      // {
      a =
        let
          cmd = pkgs.writeShellScriptBin "my-ls" ''
              cutoff=20
              ${ls-command} "$@" | head -n $cutoff
              num_files=$(ls -1 "$@" 2>/dev/null | wc -l | sed 's/[[:space:]]//g')
              if [ $num_files -gt $cutoff ]; then
                printf "[showing 20 of %d files]\n" $num_files
              fi
          '';
        in
        "${cmd}/bin/my-ls";
      aa = "${ls-command}";
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
      shuf = "${pkgs.coreutils}/bin/shuf";

      # average = "${pkgs.R}/bin/Rscript -e 'd<-scan(\"stdin\", quiet=TRUE)' -e 'summary(d)'";

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
      ssh = "${ssh-cmd}";
      make_cpptags = "${pkgs.universal-ctags}/bin/ctags --c++-kinds=+pf --c-kinds=+p --fields=+imaSft --extra=+q -Rnu";
      d = "kitty +kitten diff";
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
      export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
      test -f ~/.nix-profile/etc/profile.d/nix.sh && . ~/.nix-profile/etc/profile.d/nix.sh
      # On one of my machines, ~/.nix-profile/.../nix.sh doesn't exist.
      # Temporarily work around this by sourcing from /nix/va/nix/profiles
      test -f ~/.nix-profile/etc/profile.d/nix.sh || . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      test -f ~/.nix-profile/etc/profile.d/nix.sh || . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      [[ -e "$HOME/.bash_profile_local" ]] && source "$HOME/.bash_profile_local"
      history -a
    '';
  };

  home.file = {
    ".tmux-linux".source = ./.tmux-linux;
    ".gdbinit".source = ./.gdbinit;
    ".ghci".source = ./.ghci;
    ".lynxrc".source = ./.lynxrc;
    # ".config/automate-everything/repos".source = ./repos.conf;
    ".latexmkrc".source = ./.latexmkrc;
    ".mailcap".source = ./.mailcap;
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
    };
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
      dracula-vim
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
      YouCompleteMe
      jedi-vim
      vimoutliner
      goyo-vim
      limelight-vim
      vim-textobj-user
      vim-markdown
    ]
    ++ myVimPlugins;
    extraConfig = builtins.readFile ./vimrc_extra
    + builtins.readFile ./zettel-md.vim
    + ''
      set cmdheight=2

      ${myVimPluginsConfig}
    '';
  };

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      clang-tools
      clang
    ];
    plugins = with pkgs.vimPlugins; [
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
      dracula-vim
    ];
    extraConfig = ''
      set completeopt=menuone,noinsert,noselect

      set cmdheight=2

      set updatetime=300

      colorscheme dracula

      " LSP and Treesitter config
      lua << END
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { }, -- List of parsers to ignore installing
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

      local cmp = require'cmp'

      local kind_icons = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "ﴯ",
        Interface = "",
        Module = "",
        Property = "ﰠ",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = ""
      }

      cmp.setup({
        formatting = {
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            -- Source
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[LuaSnip]",
              nvim_lua = "[Lua]",
              latex_symbols = "[LaTeX]",
            })[entry.source.name]
            return vim_item
          end
        },
        snippet = {
          expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
        },
        mapping = {
            ["<Tab>"] = cmp.mapping(function(fallback)
                -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                if cmp.visible() then
                  local entry = cmp.get_selected_entry()
                  if not entry then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                  end
                  cmp.confirm()
                else
                  fallback()
                end
              end, {"i","s","c",}),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
          }, {
            { name = 'buffer' },
          })
      })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', {
          sources = {
            { name = 'buffer' },
            { name = 'cmdline'},
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })

      local lspconfig = require'lspconfig'

      -- Setup lspconfig.
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        --Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        --buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

        -- Get signatures (and _only_ signatures) when in argument lists.
        require "lsp_signature".on_attach({
          doc_lines = 0,
          handler_opts = {
            border = "none"
          },
        })
      end

      local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())


      local clangd_exe = '${pkgs.clang-tools}/bin/clangd'

      -- enable C/C++ support
      lspconfig.clangd.setup {
        on_attach = on_attach,
        cmd = {
          clangd_exe,
          "--background-index",
          "--suggest-missing-includes",
          },
        capabilities = capabilities,

        }

      -- enable OCaml support
      lspconfig.ocamllsp.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }

      -- enable Rust support
      lspconfig.rust_analyzer.setup {
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150,
          },
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              },
            completion = {
              postfix = {
              enable = false,
              },
            },
          },
        },
      capabilities = capabilities,
      }

      -- enable Go support
      lspconfig.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = true,
          signs = true,
          update_in_insert = true,
        }
      )

      END

      " Enable type inlay hints
      autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }

      " Plugin settings
      let g:secure_modelines_allowed_items = [
                      \ "textwidth",   "tw",
                      \ "softtabstop", "sts",
                      \ "tabstop",     "ts",
                      \ "shiftwidth",  "sw",
                      \ "expandtab",   "et",   "noexpandtab", "noet",
                      \ "filetype",    "ft",
                      \ "foldmethod",  "fdm",
                      \ "readonly",    "ro",   "noreadonly", "noro",
                      \ "rightleft",   "rl",   "norightleft", "norl",
                      \ ]

      " Lightline
      let g:lightline = {
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'readonly', 'filename', 'modified' ] ],
            \   'right': [ [ 'lineinfo' ],
            \              [ 'percent' ],
            \              [ 'fileencoding', 'filetype' ] ],
            \ },
            \ 'component_function': {
            \   'filename': 'LightlineFilename'
            \ },
            \ }
      function! LightlineFilename()
        return expand('%:t') !=# ''' ? @% : '[No Name]'
      endfunction

      " enable syntax highlighting
      syntax enable

      " enable auto indentation
      filetype plugin indent on

      " enable a permanent gutter so that things don't move when there's an error
      set signcolumn=yes

      " show lines above and below cursor
      set scrolloff=5

      " indent two characters
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      " save undo permanently
      set undodir=~/.vimdid
      set undofile

      " configure file ignoring
      set wildignore+=*/_build/*,*.o,*.swp,*.a,*.cmi,*.cmo,*.cmx,*.cmt,*.annot,*.dylib,*.cmxa

      " incrementally search while typing
      set incsearch

      " bemove toolbar
      set guioptions-=T

      " kill beeps
      set vb t_vb=

      " backspace over newlines
      set backspace=2

      " disable folds
      set nofoldenable

      " don't redraw screen in the middle of scripts
      set lazyredraw

      " enable the status line
      set laststatus=2

      " show relative line numbers but also current line
      set relativenumber
      set number

      " No whitespace in vimdiff
      set diffopt+=iwhite

      " Make diffing better: https://vimways.org/2018/the-power-of-diff/
      set diffopt+=algorithm:patience
      set diffopt+=indent-heuristic

      " Enable mouse usage (all modes) in terminals
      set mouse=a

       " don't give |ins-completion-menu| messages.
      set shortmess+=c


      " Tell vim to remember certain things when we exit
      "  '10  :  marks will be remembered for up to 10 previously edited files
      "  "100 :  will save up to 100 lines for each register
      "  :20  :  up to 20 lines of command-line history will be remembered
      "  %    :  saves and restores the buffer list
      "  n... :  where to save the viminfo files
      set viminfo='10,\"100,:20,%,n~/.nviminfo

      " Jump to last edit position on opening file
      if has("autocmd")
        " https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
        au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      endif

      " Find files using Telescope command-line sugar.
      nnoremap <C-p> <cmd>Telescope find_files<cr>
      "nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      "nnoremap <leader>fb <cmd>Telescope buffers<cr>
      "nnoremap <leader>fh <cmd>Telescope help_tags<cr>

      set spell spelllang=en_us


    '';
  };

  home.packages = with pkgs; [
    nix
    bashInteractive
    ripgrep
    bash-completion nix-bash-completions
    graphviz
    wget
    parallel
    duc # ncdu replacement
    zip unzip p7zip
    wdiff
    fx jless # json viewer
    exa # ls
    nix-prefetch-git
    nix-prefetch-github
    rusage
    GraphEasy
    record-my-session
    bunch
    ztl_filter ztl_tagcloud
    sponge
    sshpass
    figlet toilet # ascii art
    (pkgs.callPackage onetrueawk {})
    mutt
    csvkit
    watch
    rlwrap
    colordiff
  ]
  ++ myScripts;
}
