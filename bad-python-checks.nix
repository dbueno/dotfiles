let
  dontCheckPython = d: d.overridePythonAttrs (old: { doCheck = false; });
  packageOverrides = selfPythonPackages: pythonPackages: {
    zope_testing = dontCheckPython pythonPackages.zope_testing;
    aiosmtpd = dontCheckPython pythonPackages.aiosmtpd;
    dnspython = dontCheckPython pythonPackages.dnspython;
    flit = dontCheckPython pythonPackages.flit;
    cherrypy = dontCheckPython pythonPackages.cherrypy;
    poetry = dontCheckPython pythonPackages.poetry;
    sh = dontCheckPython pythonPackages.sh;
  };
  overlay = result: prev:
    {
      python38 = prev.python38.override (old: {
        packageOverrides =
          prev.lib.composeExtensions
            (old.packageOverrides or (_: _: {}))
            packageOverrides;
          });
    };
in
  { config, lib, pkgs, ... }: {
    nixpkgs.overlays = [ overlay ];
  }

