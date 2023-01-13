result: prev: {
  kitty =
    let
      kitty = prev.kitty.override { };
    in
    kitty.overridePythonAttrs (attrs: with attrs; {
      buildInputs = buildInputs ++ (with result.darwin.apple_sdk_11_0.frameworks; [ SecurityFoundation ]);
      meta = meta // { broken = false; };
    });

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
}

