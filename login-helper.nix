# Use nix build . to build the package and create the result link
# nix build "github:greedy/hm-login-shell-helper"
# Use sudo nix-env -i ./result to install the package into the system profile
# Then add /nix/var/nix/profiles/default/bin/hm-login-shell-helper to /etc/shells so that it is a valid selection for users.
{
  config,
  hm-login-shell-helper,
  ...
}: {
  imports = ["${hm-login-shell-helper}/hm-modules/login-shell.nix"];
  home.loginShell = "${config.programs.zsh.package}/bin/zsh";
}
