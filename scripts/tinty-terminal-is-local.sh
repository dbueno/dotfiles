# Exit 0 if this shell owns the terminal on the other end of its tty, and so
# may repaint it with OSC sequences; non-zero if it does not.
#
# Over ssh it does not. The terminal belongs to the local machine and the local
# shell has already painted it. Repainting from the far end is wrong twice
# over: a palette set with OSC 4/10 is *terminal* state rather than process
# state, so this host's colours outlive the logout and sit on the local tab
# until the next local `tinty init`; and the bold text colour cannot be
# corrected from here at all, since that needs AppleScript against the local
# Terminal.app. A remote scheme of the opposite polarity therefore leaves bold
# illegible with no way for this end to put it right.
#
# Shared by zsh/rc and by tinty's hook in tinty.nix, which repaints from its
# own subprocess and so has to be gated separately from the shell.

# Escape hatch: paint anyway. For the case where the far end really is the
# machine whose terminal this is.
if [ -n "$TINTY_PAINT_OVER_SSH" ]; then
  exit 0
fi

if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ]; then
  exit 1
fi

# Inside tmux the variables above are not trustworthy on their own. The tmux
# server is started once and its environment is frozen at that moment; panes
# inherit the server's copy, not the current client's. `update-environment`
# refreshes a few variables into the session environment on each attach, and
# its default list contains SSH_CONNECTION but neither SSH_TTY nor SSH_CLIENT.
# So a shell reached by ssh -> tmux attach can see no ssh variables at all, if
# the server was first started from a local login on that host. Ask tmux for
# the session environment, which does track the current client.
#
# `show-environment` prints "NAME=value" when set and "-NAME" when not, so the
# ?* guard distinguishes set-and-non-empty from both other cases.
if [ -n "$TMUX" ] && command -v tmux > /dev/null 2>&1; then
  case "$(tmux show-environment SSH_CONNECTION 2> /dev/null)" in
    SSH_CONNECTION=?*) exit 1 ;;
  esac
fi

exit 0
