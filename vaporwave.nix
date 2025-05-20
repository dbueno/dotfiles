{
  config,
  lib,
  pkgs,
  ...
}:
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

  dracula-fzf-options = [
    # https://draculatheme.com/fzf
    # "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
    # "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
    # "--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6"
    # "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    "--color=dark"
    "--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f"
    "--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7"
  ];

  tokyonight-storm-theme = rec {
    background = "#24283b";
    foreground = "#c0caf5";
    selection_background = "#2e3c64";
    selection_foreground = "#c0caf5";
    url_color = "#73daca";
    cursor = "#c0caf5";
    cursor_text_color = "#24283b";
    comment = "#565f89";
    magenta = "#bb9af7";
    cyan = "#7dcfff";

    # Tabs
    active_tab_background = "#7aa2f7";
    active_tab_foreground = "#1f2335";
    inactive_tab_background = "#292e42";
    inactive_tab_foreground = "#545c7e";
    #tab_bar_background #1d202f

    # Windows
    active_border_color = "#7aa2f7";
    inactive_border_color = "#292e42";

    # normal
    color0 = "#1d202f";
    color1 = "#f7768e";
    color2 = "#9ece6a";
    color3 = "#e0af68";
    color4 = "#7aa2f7";
    color5 = "#bb9af7";
    color6 = "#7dcfff";
    color7 = "#a9b1d6";

    # bright
    color8 = "#414868";
    color9 = "#f7768e";
    color10 = "#9ece6a";
    color11 = "#e0af68";
    color12 = "#7aa2f7";
    color13 = "#bb9af7";
    color14 = "#7dcfff";
    color15 = "#c0caf5";

    # extended colors
    color16 = "#ff9e64";
    color17 = "#db4b4b";
  };

  tokyonight-fzf-options = with tokyonight-storm-theme; [
    "--color=bg:${background},bg+:${selection_background},fg:${foreground},fg+:${selection_foreground}"
    "--color=border:${inactive_border_color},spinner:${foreground}"
    "--color=hl:${comment},hl+:${magenta},info:${cyan},prompt:${foreground},pointer:${foreground},marker:${cyan},header:${comment}"
  ];
in
{
  # dracula
  programs.fzf.defaultOptions = tokyonight-fzf-options;

  programs.git.extraConfig.color.diff = with draculaTheme; {
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

  programs.vim.plugins = [ pkgs.vimPlugins.dracula-vim ];
  programs.vim.extraConfig = ''
    " vaporwave plz
    colorscheme dracula
    " lighten up dracula comments
    augroup my_colorschemes
      au!
      au Colorscheme dracula hi Comment guifg=#7c8ca8 ctermfg=69
    augroup END
  '';

  programs.neovim.plugins = [ pkgs.vimPlugins.dracula-vim ];

  programs.bat.config.theme = "Dracula";
  programs.bat.themes = {
    dracula = {
      src = builtins.fetchGit {
        url = "https://github.com/dracula/sublime.git";
        rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
      };
      file = "Dracula.tmTheme";
    };
  };
}
