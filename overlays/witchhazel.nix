result: prev: {
  vimPlugins = prev.vimPlugins // {
    witchhazel-vim = result.vimUtils.buildVimPlugin rec {
      pname = "witchhazel";
      version = "e0999cd2a9c71e41a19191c307297df2d8fa583d";
      src = result.fetchFromGitHub {
        owner = "theacodes";
        repo = "${pname}";
        rev = "${version}";
        hash = "sha256-8zq4cnugvWPTsuLqC1X++BmVTaKqUVMQLeqyQkpdJWA=";
      };
    };
  };
}
