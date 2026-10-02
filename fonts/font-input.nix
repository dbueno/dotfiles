{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    input-fonts
  ];
}
