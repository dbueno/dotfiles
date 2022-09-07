{ stdenv, bison, yacc, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "onetrueawk";
  version = "20210724";
  src = fetchFromGitHub {
    owner = "${pname}";
    repo = "awk";
    rev = "f9affa922c5e074990a999d486d4bc823590fd93";
    sha256 = "06590dqql0pg3fdqpssh7ca1d02kzswddrxwa8xd59c15vsz9r42";
  };
  patchPhase = '' substituteInPlace makefile --replace 'gcc' 'cc' '';
  nativeBuildInputs = [ bison yacc ];
  installPhase = ''
    mkdir -p $out/bin
    cp a.out $out/bin/onetrueawk
  '';
}
