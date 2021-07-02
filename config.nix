{
  packageOverrides = pkgs: with pkgs; {
    myVim = vim_configurable.override { darwinSupport = true; guiSupport = true; };
  };
}
