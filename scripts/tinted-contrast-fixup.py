"""Repair low-contrast colours after tinty applies a scheme.

Two problems this fixes, both of which bite hardest on light schemes:

1. Terminal.app draws bold text in a colour that lives in the *profile*
   (TextBoldColor). There is no OSC escape for it -- tinted-shell only sets a
   bold colour under `if [ -n "$ITERM_SESSION_ID" ]`, iTerm2's proprietary Pi
   code -- so it keeps whatever the profile was saved with. Apply a light
   scheme on top of a profile saved from a dark one and bold renders white on
   white. AppleScript *can* reach it, per tab, so that is what we use.

2. Most base24 light schemes define base12-base17 (the bright ANSI bank) as
   colours meant for a dark background: 23 of the 31 light schemes shipped by
   tinted-schemes have at least one bright under 3:1 against their own base00,
   and 11 have a base05 foreground under 4.5:1. We darken (or on dark schemes,
   lighten) the offenders just far enough to clear a contrast floor, keeping
   hue and saturation so the scheme still looks like itself.

We read the palette back out of the shell theme file tinty just rendered
rather than the scheme YAML, so whatever mapping tinted-shell chose from base*
to ANSI slot is the mapping we correct -- base16 and base24 alike.
"""

import os
import re
import subprocess
import sys

# Contrast floors, as WCAG ratios against the scheme background. Overridable so
# a scheme that comes out too muddy can be dialled back without editing this.
FG_MIN = float(os.environ.get("TINTED_CONTRAST_FG", "4.5"))
ANSI_MIN = float(os.environ.get("TINTED_CONTRAST_ANSI", "4.5"))
BOLD_MIN = float(os.environ.get("TINTED_CONTRAST_BOLD", "7.0"))
# The bright bank gets a higher floor than the normal one, for two reasons.
# It keeps the two banks distinguishable -- clamp both to the same ratio and
# green and bright green land on the same pixel -- and it preserves what
# "bright" is for. On a light background a literally brighter colour is a
# *less* readable one, so the only coherent reading of the bright bank there
# is "more emphatic", which means further from the background, same as it
# means on a dark background.
BRIGHT_MIN = float(os.environ.get("TINTED_CONTRAST_BRIGHT", "6.0"))

# The six chromatic slots in each bank. 0/7/8/15 are the greys the scheme uses
# for structure -- dim text, selections, and in the inverted light schemes the
# background itself -- and rewriting those does more harm than good.
NORMAL_SLOTS = [1, 2, 3, 4, 5, 6]
BRIGHT_SLOTS = [9, 10, 11, 12, 13, 14]

DEBUG = bool(os.environ.get("TINTED_CONTRAST_DEBUG"))


def log(msg):
    if DEBUG:
        print("tinted-contrast-fixup: %s" % msg, file=sys.stderr)


# --- colour maths ----------------------------------------------------------


def to_linear(c):
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4


def luminance(rgb):
    r, g, b = (to_linear(v / 255.0) for v in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    if la < lb:
        la, lb = lb, la
    return (la + 0.05) / (lb + 0.05)


def rgb_to_hsl(rgb):
    r, g, b = (v / 255.0 for v in rgb)
    hi, lo = max(r, g, b), min(r, g, b)
    lightness = (hi + lo) / 2
    if hi == lo:
        return 0.0, 0.0, lightness
    d = hi - lo
    s = d / (2 - hi - lo) if lightness > 0.5 else d / (hi + lo)
    if hi == r:
        h = (g - b) / d + (6 if g < b else 0)
    elif hi == g:
        h = (b - r) / d + 2
    else:
        h = (r - g) / d + 4
    return h / 6, s, lightness


def hsl_to_rgb(h, s, lightness):
    if s == 0:
        v = round(lightness * 255)
        return (v, v, v)

    def hue(p, q, t):
        t %= 1
        if t < 1 / 6:
            return p + (q - p) * 6 * t
        if t < 1 / 2:
            return q
        if t < 2 / 3:
            return p + (q - p) * (2 / 3 - t) * 6
        return p

    q = lightness * (1 + s) if lightness < 0.5 else lightness + s - lightness * s
    p = 2 * lightness - q
    return tuple(round(hue(p, q, h + off) * 255) for off in (1 / 3, 0, -1 / 3))


def adjust(rgb, bg, target):
    """Move `rgb` away from `bg` in HSL lightness until it clears `target`.

    Hue and saturation are held fixed, so a washed-out yellow becomes a darker
    yellow rather than a different colour. Binary search converges in ~20 steps
    because contrast is monotonic in lightness once the direction is fixed.
    """
    if contrast(rgb, bg) >= target:
        return rgb

    h, s, cur = rgb_to_hsl(rgb)
    # Away from the background. Which way that is is decided by asking which
    # extreme actually stands further off it, rather than by a lightness
    # threshold: black and white pull even at a relative luminance of 0.179,
    # not 0.5, so a mid-tone background like unikitty's is misjudged by eye.
    darken = contrast((0, 0, 0), bg) >= contrast((255, 255, 255), bg)
    # `lo` is where we are, `hi` the extreme we are heading for.
    lo, hi = cur, (0.0 if darken else 1.0)

    if contrast(hsl_to_rgb(h, s, hi), bg) < target:
        # Even pure black/white at this hue cannot clear the floor; take it.
        return hsl_to_rgb(h, s, hi)

    for _ in range(24):
        mid = (lo + hi) / 2
        if contrast(hsl_to_rgb(h, s, mid), bg) >= target:
            hi = mid
        else:
            lo = mid
    return hsl_to_rgb(h, s, hi)


# --- palette source --------------------------------------------------------


def parse_theme_file(path):
    """Pull the applied palette out of tinted-shell's rendered script."""
    text = open(path).read()
    colors = {}
    for name, value in re.findall(r'^(color\w+)="([0-9a-fA-F/]+)"', text, re.M):
        parts = value.split("/")
        if len(parts) != 3:
            continue
        rgb = tuple(int(p, 16) for p in parts)
        if name.startswith("color_"):
            colors[name[6:]] = rgb
        else:
            colors[int(name[5:])] = rgb
    return colors


# --- output ----------------------------------------------------------------


def osc_writer(tty):
    """Match tinted-shell's own multiplexer passthrough handling."""
    term = os.environ.get("TERM", "")
    base = re.split(r"[-.]", term)[0]
    if os.environ.get("TMUX") or base == "tmux":
        wrap = lambda body: "\033Ptmux;\033\033]%s\033\033\\\033\\" % body
    elif base == "screen":
        wrap = lambda body: "\033P\033]%s\007\033\\" % body
    else:
        wrap = lambda body: "\033]%s\033\\" % body

    def emit(body):
        tty.write(wrap(body))

    return emit


def hexstr(rgb):
    return "%02x%02x%02x" % rgb


# --- Terminal.app bold colour ----------------------------------------------


def srgb_to_terminal(rgb):
    """Terminal.app's AppleScript colours are Generic RGB (gamma 1.8), 0-65535.

    Verified against a live tab: an OSC-10 foreground of #a1a1a1 reads back as
    36944, which is exactly round(linear(0xa1) ** (1/1.8) * 65535).
    """
    out = []
    for v in rgb:
        linear = to_linear(v / 255.0)
        out.append(round((linear ** (1 / 1.8)) * 65535))
    return out


def controlling_tty():
    """The tty of the Terminal.app tab that owns the bold colour.

    Under tmux the tab is the *client's* tty, not our pane's pty -- bold is
    rendered by Terminal.app, so the pane pty would never match a tab. Outside
    tmux, try each standard fd: the tinty wrapper in zsh/rc calls us with
    stdout redirected to /dev/null, so fd 1 is not reliably the terminal.
    """
    if os.environ.get("TMUX"):
        try:
            out = subprocess.run(
                ["tmux", "display-message", "-p", "#{client_tty}"],
                capture_output=True, text=True, timeout=5,
            ).stdout.strip()
            if out:
                return out
        except Exception as exc:  # noqa: BLE001
            log("tmux client_tty lookup failed: %s" % exc)

    for fd in (0, 2, 1):
        try:
            return os.ttyname(fd)
        except OSError:
            continue
    return None


def set_terminal_bold(rgb, tty_path):
    script = """
    tell application "Terminal"
      repeat with w in windows
        try
          repeat with t in tabs of w
            if tty of t is "%s" then
              set bold text color of t to {%d, %d, %d}
              return "ok"
            end if
          end repeat
        end try
      end repeat
      return "no-tab"
    end tell
    """ % ((tty_path,) + tuple(srgb_to_terminal(rgb)))
    try:
        res = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            timeout=5,
        )
        log("osascript: %s%s" % (res.stdout.strip(), res.stderr.strip()))
    except Exception as exc:  # noqa: BLE001 - never break a shell startup
        log("osascript failed: %s" % exc)


# --- main ------------------------------------------------------------------


def main():
    data_dir = os.environ.get("TINTY_DATA_DIR") or os.path.join(
        os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")),
        "tinted-theming",
        "tinty",
    )
    theme_file = os.path.join(data_dir, "tinted-shell-scripts-file.sh")
    if not os.path.exists(theme_file):
        log("no theme file at %s" % theme_file)
        return

    colors = parse_theme_file(theme_file)
    bg = colors.get("background")
    fg = colors.get("foreground")
    if not bg or not fg:
        log("theme file has no fg/bg")
        return

    try:
        tty = open("/dev/tty", "w")
    except OSError:
        log("no controlling tty")
        return

    with tty:
        emit = osc_writer(tty)

        floors = [(s, ANSI_MIN) for s in NORMAL_SLOTS]
        floors += [(s, BRIGHT_MIN) for s in BRIGHT_SLOTS]
        for slot, floor in floors:
            original = colors.get(slot)
            if original is None:
                continue
            fixed = adjust(original, bg, floor)
            if fixed != original:
                log("color%02d %s -> %s" % (slot, hexstr(original), hexstr(fixed)))
                emit("4;%d;rgb:%s" % (slot, "/".join("%02x" % v for v in fixed)))

        fixed_fg = adjust(fg, bg, FG_MIN)
        if fixed_fg != fg:
            log("foreground %s -> %s" % (hexstr(fg), hexstr(fixed_fg)))
            emit("10;rgb:%s" % "/".join("%02x" % v for v in fixed_fg))

        tty.flush()

    # Bold: start from whichever of base07 (the scheme's brightest foreground,
    # which inverts to *darkest* in light schemes) and base05 already stands
    # further off the background, then push it past the bold floor. That keeps
    # bold reading as an emphasis of the body text in both polarities.
    if os.environ.get("TERM_PROGRAM") == "Apple_Terminal":
        candidates = [c for c in (colors.get(15), fixed_fg) if c]
        base = max(candidates, key=lambda c: contrast(c, bg))
        bold = adjust(base, bg, BOLD_MIN)
        log("bold %s (bg %s)" % (hexstr(bold), hexstr(bg)))
        tty_path = controlling_tty()
        if tty_path:
            set_terminal_bold(bold, tty_path)
        else:
            log("no tty found; cannot identify the Terminal.app tab")


if __name__ == "__main__":
    main()
