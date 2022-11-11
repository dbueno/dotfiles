{ config, lib, pkgs, ... }:

with builtins;
with lib.attrsets;

let
  dontCheckPython = d: d.overridePythonAttrs (old: { doCheck = false; doInstallCheck = false; });
  f = pythonPackages: attr: { name = "${attr}"; value = dontCheckPython pythonPackages."${attr}"; };
  packageOverrides = selfPythonPackages: pythonPackages:
    listToAttrs (map (f pythonPackages) [
      "zope_testing"
      "aiosmtpd"
      "dnspython"
      "flit"
      "cherrypy"
      "poetry"
      "sh"
      "astor"
      "sqlalchemy"
      "twisted"
    ]) // {
      pydantic = pythonPackages.pydantic.overridePythonAttrs (old:
        { buildInputs = [ pkgs.libxcrypt ]; }
      );
      # jsonschema = pythonPackages.jsonschema.overridePythonAttrs (old:
      #   { buildInputs = [ selfPythonPackages.pkgutil-resolve-name ]; }
      # );
    };
    # makes attributes like this:
    #   zope_testing = dontCheckPython pythonPackages.zope_testing;
  overlay = result: prev:
    {
      python38 = prev.python38.override (old: {
        packageOverrides =
          prev.lib.composeExtensions
            (old.packageOverrides or (_: _: {}))
            packageOverrides;
          });
    };
  overlay2 = result: prev: {
    python38 = prev.python38.override (old: {
      packageOverrides =
        prev.lib.composeExtensions
          (old.packageOverrides or (_: _: {}))
          packageOverrides;
        });
      };
in {
  nixpkgs.overlays = [ overlay ];
}

