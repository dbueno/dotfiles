{
  packageOverrides = super: let self = super.pkgs; in {
    vim_configurable = super.vim_configurable.override { darwinSupport = true; guiSupport = true; };
    rEnv = super.rWrapper.override {
      packages = with self.rPackages; [
        devtools
        ggplot2
        reshape2
        yaml
        optparse
      ];
    };
  };
}
