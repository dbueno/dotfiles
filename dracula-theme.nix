{ config, lib, pkgs, ... }:
let
  draculaTheme = rec {
    Background = "#282A36";
    Foreground = "#F8F8F2";
    Selection = "#44475A";
    Comment = "#6272A4";
    Red = "#FF5555";
    Orange = "#FFB86C";
    Yellow = "#F1FA8C";
    Green = "#50FA7B";
    Purple = "#BD93F9";
    Cyan = "#8BE9FD";
    Pink = "#FF79C6";
    AnsiBlack = "#21222C";
    AnsiRed = "#FF5555";
    AnsiGreen = "#50FA7B";
    AnsiYellow = "#F1FA8C";
    AnsiBlue = "#BD93F9";
    AnsiMagenta = "#FF79C6";
    AnsiCyan = "#8BE9FD";
    AnsiWhite = "#F8F8F2";
    AnsiBrightBlack = "#6272A4";
    AnsiBrightRed = "#FF6E6E";
    AnsiBrightGreen = "#69FF94";
    AnsiBrightYellow = "#FFFFA5";
    AnsiBrightBlue = "#D6ACFF";
    AnsiBrightMagenta = "#FF92DF";
    AnsiBrightCyan = "#A4FFFF";
    AnsiBrightWhite = "#FFFFFF";
    DiffText = Comment;
    DiffHeader = Comment;
    DiffInserted = Green;
    DiffDeleted = Red;
    DiffChanged = Orange;
  };
in
{
  programs.fzf.defaultOptions = [
    # https://draculatheme.com/fzf
    # "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
    # "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
    # "--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6"
    # "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    "--color=dark"
    "--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f"
    "--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7"
  ];

  programs.dircolors.settings = (import ./kitty-themes/dracula/dircolors.nix);

  programs.git.extraConfig.color.diff =
    with draculaTheme; {
      context = Foreground;
      meta = Comment;
      frag = DiffHeader;
      func = "${Green}";
      commit = "${Yellow} bold";
      old = DiffDeleted;
      oldMoved = DiffDeleted;
      new = DiffInserted;
      newMoved = DiffInserted;
      whitespace = DiffDeleted;
    };

  programs.kitty.extraConfig = builtins.readFile (builtins.fetchGit {
    url = "https://github.com/dracula/kitty.git";
    rev = "eeaa86a730e3d38649053574dc60a74ce06a01bc";
  } + "/dracula.conf");

  xdg.configFile."kitty/diff.conf".source = (pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "kitty";
      rev = "eeaa86a730e3d38649053574dc60a74ce06a01bc";
      sha256 = "3yi5e/wnLYt7b3Lkf4fhSByr18SrOzJ4zYympUQMslc=";
    } + "/diff.conf");

  programs.vim.plugins = [ pkgs.vimPlugins.dracula-vim ];
  programs.vim.extraConfig = ''
    " vaporwave plz
    colorscheme dracula
  '';

  programs.neovim.plugins = [ pkgs.vimPlugins.dracula-vim ];
  programs.neovim.extraConfig = ''
      colorscheme dracula
  '';

  programs.bat.config.theme = "Dracula";
  programs.bat.themes = {
    dracula = builtins.readFile (builtins.fetchGit {
      url = "https://github.com/dracula/sublime.git";
      rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
    } + "/Dracula.tmTheme");
    };
}
