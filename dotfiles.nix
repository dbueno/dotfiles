# Links all the files under dotfiles to my home directory
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # See
  # https://github.com/nix-community/home-manager/issues/3849

  home.file =
    with pkgs;
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
    toHomeFiles ./dotfiles;
}
