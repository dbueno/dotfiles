"""Pygments style using the ANSI palette maintained by tinty.

Tinted shell maps Base16 and Base24 accents to ANSI slots 1-6. Keeping the
style in those slots lets a running litecli follow terminal palette changes.
The terminal's default foreground/background supply the scheme's base05/base00.
"""

from pygments.style import Style
from pygments.token import Comment, Error, Generic, Keyword, Name, Number, Operator, String, Token


class TintedStyle(Style):
    background_color = None
    default_style = ""
    styles = {
        Token: "",
        Comment: "italic",
        Error: "ansired",
        Generic.Error: "ansired",
        Generic.Heading: "ansiblue",
        Generic.Subheading: "ansiblue",
        Keyword: "ansimagenta",
        Keyword.Constant: "ansicyan",
        Keyword.Type: "ansiyellow",
        Name.Builtin: "ansicyan",
        Name.Class: "ansiblue",
        Name.Decorator: "ansimagenta",
        Name.Function: "ansiblue",
        Name.Label: "ansiblue",
        Number: "ansiyellow",
        Operator: "ansicyan",
        String: "ansigreen",
        String.Escape: "ansicyan",
    }
