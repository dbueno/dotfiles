# This version should have a bugfix that I need.
result: prev: {
  vim_configurable = prev.vim_configurable.overrideAttrs (attrs: with attrs; rec {
    version = "9.0.0859";
    src = result.fetchFromGitHub {
      owner = "vim";
      repo = "vim";
      rev = "v${version}";
      sha256 = "O+X3gxKj/K0kl4aoCAfZbDn7b/YwvtTuOwIiUwixr+A=";
    };
  });
}
