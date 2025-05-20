{
  stdenv,
  fetchzip,
}:
let
  version = "0.9.97";
in
stdenv.mkDerivation rec {
  pname = "hammerspoon";
  inherit version;

  src = fetchzip {
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${version}/Hammerspoon-${version}.zip";
    sha256 = "sha256-13cGdXjWeig0hUTdiCmiQdq3wcnbPOjnRRAA7hMn690=";
  };

  installPhase = ''
    mkdir -p $out/Applications/Hammerspoon.app
    mv ./* $out/Applications/Hammerspoon.app
    chmod +x "$out/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"
  '';

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    # license = stdenv.lib.licenses.mit;
    homepage = "https://www.hammerspoon.org";
    # platforms = stdenv.lib.platforms.darwin;
  };
}
