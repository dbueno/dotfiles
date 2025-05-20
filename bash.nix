{
  config,
  lib,
  pkgs,
  ...
}: let
  ssh-script = pkgs.writeShellScriptBin "my-ssh" ''
    env ssh "$@"
  '';
  ssh-cmd = "${ssh-script}/bin/my-ssh";
  completeAlias = pkgs.callPackage ./pkgs/complete-alias/default.nix {};
in {
  home.packages = with pkgs; [
    bashInteractive
    bash-completion
    nix-bash-completions
  ];

  programs.bash = {
    enable = true;
    historySize = 1000000;
    # The & removes dups; [ ]* ignores commands prefixed with spaces.  Other
    # commands, like job control and ls'ing are also ignored.
    historyIgnore = ["\"&\"" "\"[ ]*\"" "exit" "pwd" "\"[bf]g\"" "no" "lo" "lt" "pd" "c" "a" "aa" "s" "ss" "\"g a\"" "\"g s\"" "\"g ss\"" "reset"];

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
      GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
      RSVG_CONVERT = "${pkgs.librsvg}/bin/rsvg-convert";
    };

    shellAliases =
      (import ./shell-aliases.nix {inherit config lib pkgs;})
      // {
        # Greps and displays with less, with colors
        rgl = ''rg --line-buffered --pretty "$@" | less -R'';
        # Greps and fuzzy selects
        rgfzf = ''rg "$@" | fzf'';
      };

    # Settings for interactive shells
    # .bashrc is executed for interactive non-login shells
    bashrcExtra =
      builtins.readFile ./config/bashrc_extra
      + builtins.readFile ./config/bash_completion
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

  programs.dircolors.enableBashIntegration = true;
}
