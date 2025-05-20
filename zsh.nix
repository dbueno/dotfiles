{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";
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
      PAGER = "less -R";
    };

    history = {
      size = 1200000;
      save = 1000000;
      ignorePatterns = ["&\n" "exit\n" "pwd\n" "fg\n" "bg\n" "pd\n" "a\n" "aa\n" "al\n" "g reset*" "git reset*"];
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = false;
    };

    cdpath = ["." "~/work/inprogress"];

    shellAliases = import ./shell-aliases.nix {inherit config lib pkgs;};

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        export LANG="en_US.UTF-8"
        setopt incappendhistory
        setopt histsavenodups
        setopt histexpiredupsfirst
        setopt hist_no_store # don't store "history" command in history
        fpath=(${config.xdg.configHome}/zsh/vendor-completions \
               $fpath)
      '')
      ''
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

        # Setting and jumping to topic windows
        function list-topics {
          kitten @ ls | jq -r ".[].tabs[].windows[].user_vars.topic | select(. != null)"
        }
        function set-topic {
          if test -z "$1"; then
            echo "error: need topic argument"
            return 1
          fi
          kitten @ set-user-vars topic="$1"
        }
        function topics {
          f=`mktemp -t swwin XXXXXX`
          list-topics > "$f"
          topic=$(cat "$f" | fzf | tr -d "\n")
          rm -f "$f"
          kitten @ focus-window --match var:topic=$topic
        }
        function switch-tab {
          f=`mktemp -t swtab XXXXXX`
          list-topics > "$f"
          topic=$(cat "$f" | fzf | tr -d "\n")
          rm -f "$f"
          kitten @ focus-tab --match var:topic=$topic
        }

        # PS1 settings are for interactive shells (login or no), so they should be
        # set in .bashrc.
        # Colors the prompt red if the exit code argument isn't 0.
        function __colorcode_exit {
            if test "$1" -eq 0; then
                print "%{%F{white}%B%};%{%f%b%}"
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
        mypromptcommand() {
          PS1="$(__colorcode_exit $?) "
        }
        precmd_functions+=(mypromptcommand)

        . $HOME/.zshrc_local
      ''
    ];
  };

  # XXX no idea
  # system.environment.pathsToLink = [ "/share/zsh" ];

  home.packages = with pkgs; [
    zsh-completions
  ];

  programs.dircolors.enableZshIntegration = true;

  xdg.configFile."zsh/vendor-completions".source = with pkgs; let
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
