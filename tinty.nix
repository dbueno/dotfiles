{
  config,
  lib,
  pkgs,
  ...
}:
# tinty (https://github.com/tinted-theming/tinty) drives terminal and editor
# theming: one `tinty apply` renders the chosen base16 or base24 scheme into
# every template listed below. The binary comes from nixpkgs; upstream's flake
# would drag in rust-overlay and build it from source.
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

  # Repairs two things tinty cannot: Terminal.app's bold text colour, which is
  # a profile setting with no OSC escape behind it (so a light scheme applied
  # over a profile saved from a dark one draws bold white-on-white), and the
  # bright ANSI bank of the base24 light schemes, which is largely inherited
  # from dark-background palettes. See the script's docstring. Runs from the
  # tinty wrapper in zsh/rc, which has the tty the corrections must land on.
  tinted-contrast-fixup = pkgs.writeShellScriptBin "tinted-contrast-fixup" ''
    exec ${pkgs.python3}/bin/python3 ${./scripts/tinted-contrast-fixup.py} "$@"
  '';

  # Decides whether this host may repaint the terminal at all: false over ssh,
  # where the terminal is the *local* machine's and has already been painted
  # there. Shared with zsh/rc, because the two ways a theme reaches the
  # terminal -- the hook below, and the shell re-sourcing the same script to
  # pick up its variables -- have to be gated separately.
  tinty-terminal-is-local = pkgs.writeShellScriptBin "tinty-terminal-is-local" (
    builtins.readFile ./scripts/tinty-terminal-is-local.sh
  );
in
{
  home.packages = [
    pkgs.tinty
    tinted-contrast-fixup
    tinty-terminal-is-local
  ];

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
    hook = "if ${tinty-terminal-is-local}/bin/tinty-terminal-is-local; then source \"$TINTY_THEME_FILE_PATH\"; fi"
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
