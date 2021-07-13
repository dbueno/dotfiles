{ config, pkgs, ... }:

let
  nixFlakes =
    (pkgs.writeShellScriptBin "nixFlakes" ''
        exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '');
in

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dbueno";
  home.homeDirectory = "/Users/dbueno";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    nix-direnv.enableFlakes = true;
  };

  home.packages = [
    pkgs.bashInteractive_5
    pkgs.git
    pkgs.git-lfs
    pkgs.kitty
    pkgs.myVim
    pkgs.fzf
    pkgs.ripgrep
    pkgs.bash-completion
    pkgs.nix-bash-completions
    pkgs.graphviz
    pkgs.wget
    pkgs.htop
    nixFlakes
  ];
}
