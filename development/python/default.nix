{
  config,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    # (import ./overlays/YouCompleteMe.nix)
  ];

  programs.vim.plugins = with pkgs.vimPlugins; [
    # YouCompleteMe
    # jedi-vim
  ];
}
