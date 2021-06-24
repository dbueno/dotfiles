{
  packageOverrides = pkgs: with pkgs; {
    myVim = vim_configurable.override { darwinSupport = true; guiSupport = true; };
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/ce38dff.tar.gz";
      sha256 = "0pqrkm76lcmq5ywg574980l8x54zmha7bpmnlyya8w0nllrm5b6a";
    }) {
      inherit pkgs;
    };
  };
}
