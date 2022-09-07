{ mkYarnPackage, fetchFromGitHub }:
mkYarnPackage {
  src = fetchFromGitHub {
    owner = "rtfpessoa";
    repo = "diff2html-cli";
    rev = "v4.2.1";
    hash = "sha256-Z0beAIXQq85qWUSE7F1azNIYekUJoiBNqdLtDUwH82Q=";
  };

  buildPhase = ''
    yarn --offline run build
  '';

  meta = {
    mainProgram = "diff2html";
  };
}

