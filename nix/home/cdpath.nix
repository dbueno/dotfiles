# Directories `cd` searches for a relative name, after the current directory.
{
  config,
  lib,
  ...
}:
{
  options.dotfiles.cdpath = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Directories to search for `cd <dir>`, after the current one. Use
      absolute paths: the shells get them quoted, so `~` would not expand.
    '';
  };

  config = {
    # A definition, not the option's default, so other modules' entries add
    # to it rather than replace it.
    dotfiles.cdpath = [
      "${config.home.homeDirectory}/work/inprogress"
      "${config.home.homeDirectory}/proj"
    ];
    programs.zsh.cdpath = [ "." ] ++ config.dotfiles.cdpath;
  };
}
