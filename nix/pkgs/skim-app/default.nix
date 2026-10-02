{
  stdenv,
  fetchurl,
  undmg,
  unzip,
  lib,
}:
let
  version = "1.7";
in
stdenv.mkDerivation {
  pname = "skim-app";
  inherit version;
  src = fetchurl {
    name = "Skim-${version}.dmg";
    url = "https://sourceforge.net/projects/skim-app/files/Skim/Skim-${version}/Skim-${version}.dmg/download";
    sha256 = "1wfm60qwf7232c07jws4nqp5h9mn13zfvr2knc4pplfggcqs2w6n";
  };
  sourceRoot = "Skim.app";
  nativeBuildInputs = [
    undmg
    unzip
  ];
  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out/Applications/Skim.app
    cp -pR * "$out/Applications/Skim.app"
    chmod +x "$out/Applications/Skim.app/Contents/MacOS/Skim"
  '';

  meta = {
    description = "Skim is a PDF reader and note-taker for OS X";
    homepage = "https://skim-app.sourceforge.io";
    platforms = lib.platforms.darwin;
  };
}
