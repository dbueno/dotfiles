{
  config,
  lib,
  pkgs,
  ...
}:
with builtins;
with lib.attrsets; let
  dontCheckPython = d:
    d.overridePythonAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  f = pythonPackages: attr: {
    name = "${attr}";
    value = dontCheckPython pythonPackages."${attr}";
  };
  packageOverrides = selfPythonPackages: pythonPackages: let
    pkgutil-resolve-name = pythonPackages.buildPythonPackage rec {
      pname = "pkgutil_resolve_name";
      version = "1.3.10";
      src = pythonPackages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-NX1snmp1VlPP14iTgXwIU682XdUeyX89NYqBk3O70XQ=";
      };
      buildInputs = with super; [];
    };
  in
    listToAttrs (map (f pythonPackages) [
      "zope_testing"
      "aiosmtpd"
      "dnspython"
      "flit"
      "cherrypy"
      "sh"
      "astor"
      "sqlalchemy"
      "twisted"
      # "poetry"
    ])
    // {
      pydantic = pythonPackages.pydantic.overridePythonAttrs (
        old: {buildInputs = [pkgs.libxcrypt];}
      );
      # poetry = dontCheckPython (pythonPackages.poetry.overridePythonAttrs (old:
      #   { buildInputs = [ selfPythonPackages.pyxattr ]; }
      # ));
      jsonschema = pythonPackages.jsonschema.overridePythonAttrs (
        old: {buildInputs = [pkgutil-resolve-name];}
      );
    };
  # makes attributes like this:
  #   zope_testing = dontCheckPython pythonPackages.zope_testing;
  overlay = result: prev: {
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
  nixpkgs.overlays = [overlay];
}
