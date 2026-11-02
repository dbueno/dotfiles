# Builds the python3 packages named in dotfiles.python.dontCheckPackages
# without running their tests.
{
  config,
  lib,
  ...
}:
let
  dontCheckPython =
    d:
    d.overridePythonAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  packageOverrides =
    _: pythonPackages:
    lib.genAttrs config.dotfiles.python.dontCheckPackages (
      name: dontCheckPython pythonPackages.${name}
    );
  overlay = _: prev: {
    python3 = prev.python3.override (old: {
      packageOverrides = lib.composeExtensions (old.packageOverrides or (_: _: { })) packageOverrides;
    });
  };
in
{
  options.dotfiles.python.dontCheckPackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Names of python3 packages to build without running their tests, e.g.
      ones whose tests need the network.
    '';
  };

  config = {
    # A definition, not the option's default, so other modules' entries add
    # to it rather than replace it.
    dotfiles.python.dontCheckPackages = [ "dbf" ];
    nixpkgs.overlays = [ overlay ];
  };
}
