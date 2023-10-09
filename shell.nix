{ config, lib, pkgs, rusage, ... }:
let
  onetrueawk = pkgs.callPackage ./pkgs/onetrueawk/default.nix {};
  diff2html = pkgs.callPackage ./pkgs/diff2html/default.nix {};
  GraphEasy = pkgs.callPackage ./pkgs/GraphEasy/default.nix {};

  marked = pkgs.buildNpmPackage {
    pname = "marked";
    version = "v9.0.3";
    src = pkgs.fetchurl {
      url = "https://github.com/markedjs/marked/archive/refs/tags/v9.0.3.tar.gz";
      sha512 = "3hx9npd15nwcgbqcn63984q0kpsvipd9xm9dn29r5mfxap7433b2c62840vdxkdmkg8rp63pzrc53hy0d60lk1pnx6ixl1d4da0gill";
    };

    npmDepsHash = lib.fakeHash;
  };

  bunch = pkgs.writeShellScriptBin "bunch" (builtins.readFile ./scripts/bunch.sh);

  sponge = pkgs.writeShellScriptBin "sponge" ''
    # Just calls moreutils sponge
    ${pkgs.moreutils}/bin/sponge "$@"
  '';

  # Filters all zettel notes, then print the contents of each zettel, for a
  # subsequent fzf.vim search.
  ztl_filter = pkgs.writeShellScriptBin "ztl_filter" ''
    rg -l -0 '#ztl' | xargs -0 rg --column --line-number --no-heading --color=always --smart-case -- '^|#ztl'
  '';

  ztl_tagcloud = pkgs.writeShellScriptBin "ztl_tagcloud" ''
    rg --no-column --no-line-number -I -o -w '#\w[a-zA-Z0-9_-]*' | sort | uniq
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
      (pkgs.writeShellScriptBin "ifnewer" (builtins.readFile ./automation/ifnewer.sh))
      (pkgs.writeShellScriptBin "wtf" (builtins.readFile ./automation/wtf.sh))
      (pkgs.writeShellScriptBin "sync-my-repos" (builtins.readFile ./automation/sync-my-repos.sh))
      (pkgs.writeShellScriptBin "frequency" (builtins.readFile ./automation/frequency.sh))
    ];
    diff-so-fancy-git-config = {
      programs.git.extraConfig = {
        core.pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy | less --tabs=4 -RFX";
        interactive.diffFilter = "${pkgs.diff-so-fancy}/bin/diff-so-fancy --patch";
        # Works around what is apparently a git bug in parsing diff-so-fancy's
        # ansi directives. This reverts git to an older interactive diff engine
        # that doesn't have this parsing problem.
        add.interactive.useBuiltin = false;
      };
    };
    delta-git-config = {
      programs.git.extraConfig = {
        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        # Works around what is apparently a git bug in parsing diff-so-fancy's
        # ansi directives. This reverts git to an older interactive diff engine
        # that doesn't have this parsing problem.
        add.interactive.useBuiltin = false;
        delta = {
          navigate = true;
          light = false;
          syntax-theme = "Dracula";
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
      };
    };
    diff-git-config = delta-git-config;
in
{
  imports = [
    diff-git-config
    (import ./vim.nix)
    (import ./neovim.nix)
  ];

  nixpkgs.overlays = [
    (import ./overlays/diff-so-fancy.nix)
  ];

  nixpkgs.config.allowUnfree = true;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
    extraPackages = with pkgs.bat-extras; [ batdiff ];
  };

  programs.dircolors = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = ''rg --iglob '!/_opam' --iglob '!/_build' --iglob '!*.o' --files --hidden'';
    defaultOptions = [ "-m" ];
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
      # Force git to make me set an email inside each repo.
      user.useConfigOnly = true;
      init = { defaultBranch = "main"; };
      core = {
        sshCommand = "${pkgs.openssh}/bin/ssh -F ~/.ssh/config";
      };
      diff = {
        tool = "kitty";
        guitool = "kitty.gui";
      };
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
      };
      branch.sort = "creatordate";
    };
  };

  programs.htop = {
    enable = true;
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./config/kitty.conf;
  };

  xdg = {
    enable = true;
    configFile."mutt/muttrc".source = ./.muttrc;

    # Datalog snippets, see ./dotvim/after/ftplugin/souffle.vim for keybindings
    configFile."vim/snippets/datalog/rule.dl".text = ''
      Head(x, y) :-
          Foo(x, z), Bar(z, y).
    '';
    configFile."vim/snippets/datalog/decl.dl".text = ''
      .decl Foo(a: symbol, b: number)
    '';
    configFile."vim/snippets/datalog/type.dl".text = ''
      .type Ty <: symbol
    '';
    configFile."vim/snippets/datalog/macro.dl".text = ''
      #define Foo(a, b) \
        Bar(a, b) :- \
          Baz(b, c)
    '';
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

  home.file = {
    ".tmux-linux".source = ./.tmux-linux;
    ".gdbinit".source = ./.gdbinit;
    ".ghci".source = ./.ghci;
    ".lynxrc".source = ./.lynxrc;
    # ".config/automate-everything/repos".source = ./repos.conf;
    ".latexmkrc".source = ./.latexmkrc;
    ".mailcap".source = ./.mailcap;
    ".ctags".text = ''
      --langdef=souffle
      --langmap=souffle:.dl
      --regex-souffle=/^.decl[ \t]*([a-zA-Z0-9_]+)/\1/d,definition/
      --regex-souffle=/^.type[ \t]*([a-zA-Z0-9_]+)/\1/d,definition/
      --regex-souffle=/^#define[ \t]*([a-zA-Z0-9_]+)/\1/d,definition/
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./config/tmux.conf;
    terminal = "screen-256color";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = { identitiesOnly = true; };
      "denisbueno.net" = { user = "dbueno"; };
    };
  };

  programs.matplotlib = {
    enable = true;
  };

  programs.pandoc = {
    enable = true;
  };

  # https://github.com/nix-community/home-manager/issues/432
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" "doc" ];
  home.packages = with pkgs; [
    man-pages-posix
    nix
    gitFull
    ripgrep
    graphviz
    wget
    parallel
    duc # ncdu replacement
    zip unzip p7zip
    wdiff
    fx jless # json viewer
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
    onetrueawk
    mutt
    csvkit
    watch
    rlwrap
    # diff tools
    colordiff difftastic
    nodePackages.json-diff diff2html
    fd # find alternative
    hyperfine
    tree
    ack
    jq
    pigz xz
  ]
  ++ myScripts;
}
