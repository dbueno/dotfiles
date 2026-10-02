{
  pkgs,
  ...
}:
{
  imports = [ ../fonts/font-hack.nix ];

  home.packages = with pkgs; [
    linuxPackages.perf
    pkgs.obsidian
  ];
}
