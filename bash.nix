{ config, lib, pkgs, ... }:
let
  ssh-script = pkgs.writeShellScriptBin "my-ssh" ''
    if [[ "$TERM" = *kitty ]]; then
        env TERM=xterm-256color ssh "$@"
    else
        env ssh "$@"
    fi
    '';
  ssh-cmd = "${ssh-script}/bin/my-ssh";
  completeAlias = pkgs.callPackage ./pkgs/complete-alias/default.nix {};
in {
  home.packages = with pkgs; [
    bashInteractive
    bash-completion nix-bash-completions
  ];

  programs.kitty.settings.shell = "${pkgs.bashInteractive}/bin/bash --login -i";

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
      GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
      RSVG_CONVERT = "${pkgs.librsvg}/bin/rsvg-convert";
    };

    shellAliases =
      let
        ls-command = if pkgs.stdenv.isDarwin then "CLICOLOR_FORCE=1 ls -lFGth" else "ls -lF --color -th";
      in
      (if pkgs.stdenv.isDarwin then { lldb = "PATH=/usr/bin:$PATH lldb"; } else {})
      // {
      ztl = ''
        vim -c ":cd %:p:h" "$HOME/thearchive/202004201149 Slip-box process checklist.md"
      '';
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

        test -f "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash" && . "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
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
