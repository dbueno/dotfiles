# Links every file under each of dotfiles.homeFileDirs to the same path in the
# home directory.
{ config, lib, ... }:
let
  listFilesRecursive =
    dir: acc:
    lib.flatten (
      lib.mapAttrsToList (
        k: v: if v == "regular" then "${acc}${k}" else listFilesRecursive dir "${acc}${k}/"
      ) (builtins.readDir "${dir}/${acc}")
    );

  toHomeFiles =
    dir:
    builtins.listToAttrs (
      map (x: {
        name = x;
        value = {
          source = "${dir}/${x}";
        };
      }) (listFilesRecursive dir "")
    );
in
{
  options.dotfiles.homeFileDirs = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    description = ''
      Directories whose files are linked into the home directory at the same
      relative path. Where two directories have the same path, the later one
      wins; this module's home-files comes first.
    '';
  };

  config = {
    dotfiles.homeFileDirs = lib.mkBefore [ ../../home-files ];

    # See
    # https://github.com/nix-community/home-manager/issues/3849
    home.file = lib.foldl' (acc: dir: acc // toHomeFiles dir) { } config.dotfiles.homeFileDirs;
  };
}
