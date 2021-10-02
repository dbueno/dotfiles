{ config, lib, pkgs, ... }:

let 
  mod = "Mod1";
  refresh-i3status = "killall -SIGUSR1 i3status";
  term = "${pkgs.kitty}";
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = ["DejaVu Sans Mono 8"];

      floating.modifier = "$mod";

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ${term}";
        "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && ${refresh-i3status}";
        "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
        "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
        "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";
        "${mod}+e" = "exec --no-startup-id ${pkgs.dmenu}/bin/dmenu_run";
        "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
        "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";
        "${mod}+Shift+quotedbl" = "kill";

        # change focus
        "${mod}+h" = "focus left";
        "${mod}+t" = "focus down";
        "${mod}+n" = "focus up";
        "${mod}+s" = "focus right";

        # moved focused window
        "${mod}+Shift+H" = "move left";
        "${mod}+Shift+T" = "move down";
        "${mod}+Shift+N" = "move up";
        "${mod}+Shift+S" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";
      };

      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
        }
      ];
    };
  };
}
