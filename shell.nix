{
  config,
  lib,
  pkgs,
  ...
}:
let
  diff2html = pkgs.callPackage ./pkgs/diff2html/default.nix { };
  GraphEasy = pkgs.callPackage ./pkgs/GraphEasy/default.nix { };

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

  system-xcrun = pkgs.writeShellScriptBin "system-xcrun" (builtins.readFile ./scripts/system-xcrun);

  my-moreutils = pkgs.stdenv.mkDerivation rec {
    pname = "my-moreutils";
    version = "20231230";
    dontUnpack = true; # no source
    installPhase = ''
      mkdir -p $out/bin
      for prog in sponge vidir vipe ts; do
        ln -s ${pkgs.moreutils}/bin/$prog $out/bin/$prog
      done
    '';
  };

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

  # ssh-with-env-pass = pkgs.writeShellScriptBin "ssh-with-env-pass" ''
  #   # You could add a function like this in your environment:
  #   # function ssh-to-host() {
  #   #   SSHPASS=$(cat ~/.host-password) ssh-with-env-pass host
  #   # }
  #   ${pkgs.sshpass}/bin/sshpass -e ${ssh-cmd} "$@"
  # '';
  # rsync-with-env-pass = pkgs.writeShellScriptBin "rsync-with-env-pass" ''
  #   rsync --rsh='${pkgs.sshpass}/bin/sshpass -e ssh' "$@"
  # '';

  pythonWithNumpy = pkgs.python3.withPackages (
    p: with p; [
      pandas
      numpy
      scipy
    ]
  );

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

      less-pager = pkgs.writeShellScriptBin "less-pager" ''
        less -SXRF
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
    in
    [
      onChange
      less-pager
      google
      uncolor
      viewjson
      viewhex
      (pkgs.writeShellScriptBin "ifnewer" (builtins.readFile ./automation/ifnewer.sh))
      (pkgs.writeShellScriptBin "wtf" (builtins.readFile ./automation/wtf.sh))
      (pkgs.writeShellScriptBin "frequency" (builtins.readFile ./automation/frequency.sh))
    ];
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
  difftastic-git-difftool-config = {
    programs.git.extraConfig = {
      diff.tool = "difftastic";
    };
  };
  diff-git-config = delta-git-config;
in
{
  imports = [
    (import ./neovim.nix)
    (import ./base16.nix)
    (import ./dotfiles.nix)
    (import ./fzf.nix)
  ];

  nixpkgs.overlays = [
    (result: prev: {
      rwm-base16_synthwave-84 = pkgs.fetchFromGitHub {
        name = "rwm-source"; # This is needed so that unpacking doesn't collide with base16-shell
        owner = "ReversingWithMe";
        repo = "base16_synthwave-84";
        rev = "1c2311b6aec14365cc6ff1ab87c2fe90478f4e15";
        hash = "sha256-om35BRI97pQl0tl/B5tkwOaE/rDQC25rL/rtBGC302I=";
      };
    })
  ];

  nix.package = pkgs.nixVersions.stable;
  # nix.settings = {
  #   cores = 0;
  #   max-jobs = "auto";
  #   extra-experimental-features = [
  #     "flakes"
  #     "nix-command"
  #   ];
  # };

  nixpkgs.config.allowUnfree = true;
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #programs.dircolors = {
  #  enable = true;
  #};

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.htop = {
    enable = true;
  };

  # See below how stuff in xdg_config is linked to home dir
  xdg = {
    enable = true;
    configFile =
      let
        dir = ./xdg_config;
        entries = builtins.readDir dir;
      in
      builtins.mapAttrs
      (name: type: {
        source = dir + "/${name}";
        recursive = type == "directory";
      })
      entries;
    };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identitiesOnly = true;
      };
      "denisbueno.net" = {
        user = "dbueno";
      };
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
  home.extraOutputsToInstall = [
    "man"
    "doc"
  ];
  home.packages =
    with pkgs;
    [
      readline
      tmux
      bat
      bat-extras.batdiff
      man-pages-posix
      gitFull
      ripgrep
      ripgrep-all
      graphviz
      wget
      parallel
      duc # ncdu replacement
      zip
      unzip
      p7zip
      wdiff
      fx
      jless # json viewer
      nix-prefetch-git
      nix-prefetch-github
      rusage
      merjar
      GraphEasy
      record-my-session
      bunch
      system-xcrun
      sshpass
      figlet
      toilet # ascii art
      mutt
      csvkit
      watch
      my-moreutils
      rlwrap
      # diff tools
      colordiff
      difftastic
      json-diff
      # diff2html
      fd # find alternative
      hyperfine
      tree
      ack
      jq
      gron
      pigz
      xz
      ncdu
      entr
      delta
      nodejs
      duckdb
      visidata
      litecli
    ]
    ++ myScripts;
}
