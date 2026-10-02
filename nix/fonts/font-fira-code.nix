{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];
}
