# Links every file under home-files to the same path in the home directory.
{ lib, ... }:
{
  # See
  # https://github.com/nix-community/home-manager/issues/3849

  home.file =
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
    toHomeFiles ../../home-files;
}
