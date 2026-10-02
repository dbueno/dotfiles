{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    inconsolata
  ];
}
