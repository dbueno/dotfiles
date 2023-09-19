{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        # "nix-zsh-completions"
        "git"
        "dash"
        "fzf"
      ];
    };

    sessionVariables = {
      "FZF_BASE" = "${pkgs.fzf}/share/fzf";
      GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
      RSVG_CONVERT = "${pkgs.librsvg}/bin/rsvg-convert";
    };

    history = {
      size = 1200000;
      save = 1000000;
      ignorePatterns = [ "&*" "exit*" "pwd*" "fg*" "bg*" "pd*" "a*" "aa*" "al*" "g s*" "g ss*" "g reset *" "git reset *" "g pull\n"];
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = false;
    };

    cdpath = [ "." "~/work/inprogress" ];

    shellAliases = (import ./shell-aliases.nix { inherit config lib pkgs; });

    initExtraFirst = ''
      export LC_ALL="en_US.UTF-8"
      setopt incappendhistory
      setopt histsavenodups
      setopt histexpiredupsfirst
      setopt hist_no_store # don't store "history" command in history
      fpath=(${config.xdg.configHome}/zsh/vendor-completions \
             $fpath)
    '';

    initExtra = ''
      zshaddhistory() {
        emulate -L zsh
        ## uncomment if HISTORY_IGNORE
        ## should use EXTENDED_GLOB syntax
        setopt extendedglob
        [[ $1 != ''${~HISTORY_IGNORE} ]]
      }
      setopt pushd_ignore_dups
      setopt ignoreeof # I hit ctrl-d *all the time*, never to exit

      # case insensitive partial filename completion (??)
      zstyle ':completion:*' matcher-list \
        'm:{[:lower:]}={[:upper:]}' \
        '+r:|[._-]=* r:|=*' \
        '+l:|=*'

      # alias average="Rscript -e 'd<-scan(\"stdin\", quiet=TRUE)' -e 'cat(min(d), max(d), median(d), mean(d), sep=\"\n\")'"

      # Greps and displays with less, with colors
      function rgl {
          rg --line-buffered --pretty "$@" | less -R
      }
      # Greps and fuzzy selects
      function rgfzf {
          rg "$@" | fzf
      }
      function sortinplace {
        sort "$1" | sponge "$1"
      }
      # Displays an image (png) in the terminal
      function icat {
          kitty +kitten icat --align=left
      }
      # Displays an SVG in the terminal
      function isvg {
          "$RSVG_CONVERT" | icat
      }
      # Displays a graph in the terminal
      function idot {
          "$GRAPHVIZ_DOT" -Gbgcolor=transparent -Nfontcolor=#2E3440 -Nstyle=filled \
              -Nfillcolor=#D8DEE9 -Ecolor=#5E81AC -Efontcolor=#8FBCBB -Nfontname=Helvetica -Efontname=Helvetica \
              -Nfontsize=11 -Efontsize=10 -Gratio=compress "$@" -Tsvg | isvg
      }

      # PS1 settings are for interactive shells (login or no), so they should be
      # set in .bashrc.
      # Colors the prompt red if the exit code argument isn't 0.
      function __colorcode_exit {
          if test "$1" -eq 0; then
              print "%{%F{green}%B%};%{%f%b%}"
          else
              print "%{%F{red}%B%};%{%f%b%}"
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

      test -f "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh" && . "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh"
      . $HOME/.zshrc_local
    '';
  };

  # XXX no idea
  # system.environment.pathsToLink = [ "/share/zsh" ];

  home.packages = with pkgs; [
    zsh-completions
  ];

  programs.kitty.settings.shell = "${pkgs.zsh}/bin/zsh --login --interactive";
  programs.tmux.shell = "${pkgs.zsh}/bin/zsh";
  programs.dircolors.enableZshIntegration = true;

  xdg.configFile."zsh/vendor-completions".source =
    with pkgs;
    let
      compPackages = [home-manager nix];
    in
    runCommand "vendored-zsh-completions" {} ''
     mkdir -p $out
     echo ${lib.escapeShellArgs compPackages}
     ${fd}/bin/fd -t f '^_[^.]+$' \
       ${lib.escapeShellArgs compPackages} \
       --exec ${ripgrep}/bin/rg -0l '^#compdef' {} \
       | xargs -0 cp -t $out/
    '';
}
