{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
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
      GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
      RSVG_CONVERT = "${pkgs.librsvg}/bin/rsvg-convert";
      COREUTILS_LS = "${pkgs.coreutils}/bin/ls";
      COREUTILS_SHUF = "${pkgs.coreutils}/bin/shuf";
      UNIVERSAL_CTAGS = "${pkgs.universal-ctags}/bin/ctags";
      HM_XDG_CONFIG_HOME = "${config.xdg.configHome}";
    };

    initContent = lib.mkMerge [
      # This puts some important shell and nix stuff first so the rest of the
      # shell init can access it
      (lib.mkOrder 500 (builtins.readFile ../../assets/zsh/start))
      (builtins.readFile ../../assets/zsh/rc)
    ];

    envExtra = builtins.readFile ../../assets/zsh/env;
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
