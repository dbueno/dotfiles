{ stdenv 
, fetchurl
, undmg
, lib }:

let
  version = "v2.10.0";
in
stdenv.mkDerivation rec {
  pname = "stats";
  inherit version;

  src = fetchurl {
    url = "https://github.com/exelban/stats/releases/download/${version}/Stats.dmg";
    sha256 = "0vgpwjyci2mxiyrq2ig3gd8nkj55s66r85kgqhnq29vakj03qkqs";
  };
  # fetchurl requires a custom unpackPhase to handle dmg, fetchurl cannot handle undmg producing >1 directory without this
  sourceRoot = ".";


  nativeBuildInputs = [ undmg ];

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/Applications/
    mv ./Stats.app $out/Applications/
    chmod +x "$out/Applications/Stats.app/Contents/MacOS/Stats"
  '';

  meta = {
    description = "macOS system monitor in your menu bar";
    license = lib.licenses.mit;
    homepage = "https://github.com/exelban/stats";
    platforms = lib.platforms.darwin;
  };
}
