{ stdenv 
, fetchzip
, undmg }:

let
  version = "v2.10.0";
in
stdenv.mkDerivation rec {
  pname = "stats";
  inherit version;

  src = fetchzip {
    url = "https://github.com/exelban/stats/releases/download/${version}/Stats.dmg";
    sha256 = "sha256-00000000000000000000000000000OjnRRAA7hMn690=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    mkdir -p $out/Applications/Stats.app
    mv ./* $out/Applications/Stats.app
    chmod +x "$out/Applications/Stats.app/Contents/MacOS/Stats"
  '';

  meta = {
    description = "macOS system monitor in your menu bar";
    license = stdenv.lib.licenses.mit;
    homepage = "https://github.com/exelban/stats";
    platforms = stdenv.lib.platforms.darwin;
  };
}
