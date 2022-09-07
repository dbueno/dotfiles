# ASCII graphs from graphviz input
{ perlPackages, fetchurl, makeWrapper, lib }:
perlPackages.buildPerlPackage {
    pname = "Graph-Easy";
    version = "0.76";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SH/SHLOMIF/Graph-Easy-0.76.tar.gz";
      sha256 = "d4a2c10aebef663b598ea37f3aa3e3b752acf1fbbb961232c3dbe1155008d1fa";
    };
    buildInputs = [ makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/graph-easy --set PERL5LIB ${perlPackages.makeFullPerlPath []}
    '';
    meta = {
      description = "Convert or render graphs (as ASCII, HTML, SVG or via Graphviz)";
      license = lib.licenses.gpl1Plus;
    };
  }

