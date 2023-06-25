{ config, lib, pkgs, ... }:
let
  d =
  { lib, stdenv, fetchzip }:

  stdenv.mkDerivation rec {
    pname = "intel-one-mono";
    version = "1.0.0";

    src = fetchzip {
      url = "https://github.com/intel/${pname}/releases/download/V${version}/ttf.zip";
      stripRoot = false;
      sha256 = "sha256-4XE4HS25TlwXzAh41WJS3d7T2U/qO3Hm4zlvMcgEnpU=";
    };

    installPhase = ''
      install -m644 --target $out/share/fonts/truetype/intel-one-mono -D $src/ttf/*.ttf
    '';
  };
  intel-one-mono = pkgs.callPackage d {};
in
{
  programs.kitty.settings = {
    font_family = "Intel One Mono";
    font_size = lib.mkDefault "11.0";
  };

  home.packages = [
    intel-one-mono
  ];
}
