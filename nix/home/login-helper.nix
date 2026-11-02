# Puts a `login-shell` link in the profile for hm-login-shell-helper, a login
# shell installed system-wide that runs it.
#
# Use nix build . to build the package and create the result link
# nix build "github:greedy/hm-login-shell-helper"
# Use sudo nix-env -i ./result to install the package into the system profile
# Then add /nix/var/nix/profiles/default/bin/hm-login-shell-helper to /etc/shells so that it is a valid selection for users.
#
# This replaces that flake's hm-modules/login-shell.nix, whose home.loginShell
# defaults to null but can't hold it, so leaving it unset fails evaluation.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    home.loginShell = lib.mkOption {
      type = lib.types.nullOr lib.types.pathInStore;
      default = null;
      description = "The shell hm-login-shell-helper runs, linked as `login-shell`.";
    };
    dotfiles.loginShell.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to set home.loginShell to zsh. Disable on hosts without
        hm-login-shell-helper installed system-wide.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.loginShell.enable {
      home.loginShell = "${config.programs.zsh.package}/bin/zsh";
    })
    (lib.mkIf (config.home.loginShell != null) {
      home.packages = [
        (pkgs.runCommandLocal "login-shell" { } ''
          mkdir -p $out/bin
          ln -s "${config.home.loginShell}" $out/bin/login-shell
        '')
      ];
    })
  ];
}
