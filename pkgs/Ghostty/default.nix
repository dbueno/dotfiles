{
  stdenv,
  lib,
  fetchurl,
  undmg,
  _7zz,
}:
stdenv.mkDerivation rec {
  pname = "Ghostty";
  version = "1.1.2";

  src = fetchurl {
    url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
    sha256 = "sha256-1K0BOWg0ykR/pdCE6/b7XUSVcoD6ryLqRz6WBnUcSOE=";
    #sha256 = "sha256-3KKyJOpkbhGKtq01aDGDealjI2BCL6fpz5DW6rn0A/0=";
  };
  sourceRoot = "Ghostty.app";

  nativeBuildInputs = [_7zz];
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/Applications/Ghostty.app
    cp -R . $out/Applications/Ghostty.app
  '';

  meta = {
    description = "Ghostty is a fast, feature-rich, and cross-platform terminal emulator that uses platform-native UI and GPU acceleration";
    license = lib.licenses.mit;
    homepage = "https://ghostty.org";
    platforms = lib.platforms.darwin;
  };
}
