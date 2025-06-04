{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zsh.initContent = builtins.readFile ./zsh/fzf;
  programs.zsh.sessionVariables = {
    "FZF_BASE" = "${pkgs.fzf}/share/fzf";
  };
  programs.fzf = {
    enable = true;
  };
}
