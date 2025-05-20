{
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib.attrsets;
let
  # These python packages are going to have "dontCheck = true;" added to them
  dontCheckPackages = [
    "dbf"
  ];
  dontCheckPython =
    d:
    d.overridePythonAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  f = pythonPackages: attr: {
    name = "${attr}";
    value = dontCheckPython pythonPackages."${attr}";
  };
  packageOverrides =
    selfPythonPackages: pythonPackages: listToAttrs (map (f pythonPackages) dontCheckPackages);
  overlay = result: prev: {
    python3 = prev.python3.override (old: {
      packageOverrides = prev.lib.composeExtensions (old.packageOverrides or (_: _: { })
      ) packageOverrides;
    });
  };
in
{
  nixpkgs.overlays = [ overlay ];
}
