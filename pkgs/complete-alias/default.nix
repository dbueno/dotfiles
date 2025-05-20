{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "complete-alias";
  version = "dev";
  src = fetchFromGitHub {
    owner = "cykerway";
    repo = "complete-alias";
    rev = "b16b183f6bf0029b9714b0e0178b6bd28eda52f3";
    sha256 = "1a3szf0bvj0mk2kcq1052q9xzjqiwgmavfg348dspfz543nigvk2";
  };
  installPhase = ''
    mkdir -p $out
    cp complete_alias $out/
  '';
}
