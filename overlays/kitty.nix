result: prev: {
  kitty = prev.kitty.overrideAttrs (attrs: with attrs; {
    version = "0.26.2";
    src = fetchFromGitHub {
      owner = "kovidgoyal";
      repo = "kitty";
      rev = "v0.26.2";
      sha256 = "sha256-IqXRkKzOfqWolH/534nmM2R/69olhFOk6wbbF4ifRd0=";
    };
  });
}

