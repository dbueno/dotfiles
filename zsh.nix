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
in
{
  home.packages = with pkgs; [
    zsh-completions nix-zsh-completions
  ];

  programs.kitty.settings.shell = "${pkgs.zsh}/bin/zsh --login --interactive";

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "dash"
        "fzf"
      ];
    };

    sessionVariables = {
      "FZF_BASE" = "${pkgs.fzf}/share/fzf";
    };

    history = {
      size = 1000000;
      save = 1000000;
      ignorePatterns = [ "\"&\"" "\"[ ]*\"" "exit" "pwd" "\"[bf]g\"" "no" "lo" "lt" "pd" "c" "a" "aa" "s" "ss" "\"g a\"" "\"g s\"" "\"g ss\"" "reset" ];
    };

    cdpath = [ "." "~/work/inprogress" ];

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

    initExtra = ''
      # PS1 settings are for interactive shells (login or no), so they should be
      # set in .bashrc.
      # Colors the prompt red if the exit code argument isn't 0.
      function __colorcode_exit {
          if test "$1" -eq 0; then
              # printf ";"
              printf "\033[01;32m;\033[0m"
          else
              printf "\033[01;31m;\033[0m"
          fi
      }
      function __colorcode_setps1 {
          local last_exit="$?"
          # I tried, at first, setting PS1 in .bashrc alone. But I ran into a problem
          # where the \[ and \] in __colorcode_exit were being literally printed in
          # the prompt, instead of interpreted as directives for bash. Setting PS1 in
          # PROMPT_COMMAND fixes this problem.
          PS1="$(__colorcode_exit $last_exit) "
      }
      function bueno_minimalist_prompt {
          # Default for earlier bash shells where PROMPT_COMMAND doesn't work.
          PS1="; "
          PROMPT_COMMAND+=('__colorcode_setps1')
      }
      promptcommand() { eval "$PROMPT_COMMAND" }
      precmd_functions=(promptcommand)
      bueno_minimalist_prompt
    '';
  };

  programs.dircolors.enableZshIntegration = true;
}
