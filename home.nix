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

  # My packages
  home.packages = with pkgs; [
    bashInteractive_5
    git
    git-lfs
    kitty
    myVim
    fzf
    ripgrep
    bash-completion
    nix-bash-completions
    graphviz
    wget
    parallel
    htop
    nixFlakes
  ];
}
