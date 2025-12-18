{
  config,
  lib,
  pkgs,
  ...
}:
{
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
      GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
      RSVG_CONVERT = "${pkgs.librsvg}/bin/rsvg-convert";
      COREUTILS_LS = "${pkgs.coreutils}/bin/ls";
      COREUTILS_SHUF = "${pkgs.coreutils}/bin/shuf";
      UNIVERSAL_CTAGS = "${pkgs.universal-ctags}/bin/ctags";
      HM_XDG_CONFIG_HOME = "${config.xdg.configHome}";
    };

    history = {
      size = 1200000;
      save = 1000000;
      ignorePatterns = [
        "&\n"
        "exit\n"
        "pwd\n"
        "p\n"
        "fg\n"
        "bg\n"
        "a\n"
        "aa\n"
        "al\n"
        "git reset*"
      ];
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = false;
    };

    cdpath = [
      "."
      "~/work/inprogress"
      "~/proj"
    ];

    initContent = lib.mkMerge [
      # This puts some important shell and nix stuff first so the rest of the
      # shell init can access it
      (lib.mkOrder 500 (builtins.readFile ./zsh/start))
      (builtins.readFile ./zsh/rc)
    ];

    envExtra = builtins.readFile ./zsh/env;
  };

  # XXX no idea
  # system.environment.pathsToLink = [ "/share/zsh" ];

  home.packages = with pkgs; [
    zsh-completions
  ];

  #programs.dircolors.enableZshIntegration = true;

  xdg.configFile."zsh/vendor-completions".source =
    with pkgs;
    let
      compPackages = [
        home-manager
        nix
      ];
    in
    runCommand "vendored-zsh-completions" { } ''
      mkdir -p $out
      echo ${lib.escapeShellArgs compPackages}
      ${fd}/bin/fd -t f '^_[^.]+$' \
        ${lib.escapeShellArgs compPackages} \
        --exec ${ripgrep}/bin/rg -0l '^#compdef' {} \
        | xargs -0 cp -t $out/
    '';
}
