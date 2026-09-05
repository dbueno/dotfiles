{
  config,
  lib,
  pkgs,
  ...
}:
# tinty (https://github.com/tinted-theming/tinty) replaces base16-shell. Unlike
# base16-shell it understands both the base16 and base24 systems, and it drives
# every themed tool from one `tinty apply` invocation. The binary comes from
# nixpkgs; upstream's flake would drag in rust-overlay and build it from source.
#
# Normally `tinty sync` git-clones the schemes repo and each template repo into
# its data dir at runtime. We don't: the three sources are pinned as flake inputs
# and symlinked into place below, so nothing is fetched, nothing floats on
# upstream HEAD, and tinty never needs git on PATH. `tinty apply` and `tinty
# init` are pure local template rendering and work fine that way -- only
# `sync`/`update` shell out to git, and with the repos already in place there is
# nothing left for them to do.
let
  dataDir = "${config.xdg.dataHome}/tinted-theming/tinty";
in
{
  home.packages = [ pkgs.tinty ];

  # tinty resolves each template through <data-dir>/repos/<item name>, and the
  # schemes repo through <data-dir>/repos/schemes. Owning those links here is
  # what replaces `tinty sync`.
  #
  # tinty's `[schemes].path` config key would express the schemes half of this
  # declaratively, but it is unreleased -- v0.34.1 silently ignores the table --
  # so the symlink is the working equivalent.
  home.file = {
    "${dataDir}/repos/schemes".source = pkgs.tinted-schemes;
    "${dataDir}/repos/tinted-shell".source = pkgs.tinted-shell;
    "${dataDir}/repos/tinted-vim".source = pkgs.tinted-vim;
  };

  # https://github.com/tinted-theming/tinty#configuration
  # Each item's `path` names the same store path its repos/ link points at, so
  # tinty considers the template already installed and leaves it alone.
  xdg.configFile."tinted-theming/tinty/config.toml".text = ''
    shell = "${pkgs.zsh}/bin/zsh -c '{}'"
    default-scheme = "base24-one-light"

    [[items]]
    name = "tinted-shell"
    path = "${pkgs.tinted-shell}"
    themes-dir = "scripts"
    hook = "source \"$TINTY_THEME_FILE_PATH\""
    supported-systems = ["base16", "base24"]

    [[items]]
    name = "tinted-vim"
    path = "${pkgs.tinted-vim}"
    themes-dir = "colors"
    supported-systems = ["base16", "base24"]
  '';

  # Re-render the theme files against whatever the inputs now pin. `init` reuses
  # the last applied scheme, falling back to default-scheme on a first run.
  home.activation.tintyInit = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.tinty}/bin/tinty init > /dev/null || \
      warnEcho "tinty init failed; run 'tinty init' to see why"
  '';

  home.sessionVariables = {
    # Where zsh/rc and the vimrc look for the files tinty generates.
    TINTY_DATA_DIR = dataDir;
  };
}
