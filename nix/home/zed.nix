{
  config,
  lib,
  pkgs,
  ...
}:
let
  seed = ../../home-files/.config/zed/settings-home-manager.json;
  settings = "${config.xdg.configHome}/zed/settings.json";
in
{
  # Zed writes settings.json itself. Seed it once, leaving subsequent GUI edits
  # (and any pre-existing file or symlink) entirely under Zed's control.
  home.activation.seedZedSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    target=${lib.escapeShellArg settings}
    if [[ ! -e "$target" && ! -L "$target" ]]; then
      run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/zed"}
      run ${pkgs.coreutils}/bin/cp --no-clobber --no-preserve=mode ${lib.escapeShellArg seed} "$target"
    fi
  '';
}
