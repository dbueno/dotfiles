result: prev:
  let
    kitty = result.callPackage ./kitty/default.nix {
      harfbuzz = result.harfbuzz.override { withCoreText = result.stdenv.isDarwin; };
      inherit (result.darwin.apple_sdk_11_0) Libsystem;
      inherit (result.darwin.apple_sdk_11_0.frameworks)
        Cocoa
        Kernel
        UniformTypeIdentifiers
        UserNotifications;
    };
  in
    { inherit kitty; }

  # kitty = prev.kitty.overridePythonAttrs (attrs: with attrs; {
  #   version = "0.25.2";
  #   name = "kitty-0.25.2";
  #   src = result.fetchFromGitHub {
  #     owner = "kovidgoyal";
  #     repo = "kitty";
  #     rev = "v0.25.2";
  #     # sha256 = result.lib.fakeSha256; #"sha256-IqXRkKzOfqWolH/534nmM2R/69olhFOk6wbbF4ifRd0=";
  #     sha256 = "o/vVz1lPfsgkzbYjYhIrScCAROmVdiPsNwjW/m5n7Us=";
  #   };
    # meta = meta // { broken = false; };
  # });

