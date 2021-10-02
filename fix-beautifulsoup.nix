self: super:
let
  lib = super.lib;
in
rec {
  python39 = super.python39.override {
    packageOverrides = self: super: {
      beautifulsoup4 = super.beautifulsoup4.overrideAttrs (old: {
        propagatedBuildInputs = lib.remove super.lxml old.propagatedBuildInputs;
      });
    };
  };
  python39Packages = python39.pkgs;
}

#let
#  libxml2-with-iconv = super.libxml2.overrideAttrs (attrs: {
#    propagatedBuildInputs = attrs.propagatedBuildInputs ++ self.lib.optional self.stdenv.isDarwin self.libiconv;
#  });
#in {
#  # Fix for broken python beautifulsoup... change the stdenv. Perfect.
#  # libxml2 = libxml2-with-iconv;
#
#  # Fix for broken python beautifulsoup...
#  python3 = super.python3.override {
#    # Careful, we're using a different self and super here!
#    packageOverrides = self: super: {
#      beautifulsoup4 = super.beautifulsoup4.override {
#        lxml = super.lxml.override { libxml2 = libxml2-with-iconv; };
#      };
#      # lxml = super.lxml.override { libxml2 = libxml2-with-iconv; };
#    };
#  };
#  python3Packages = self.python3.pkgs;
#}
