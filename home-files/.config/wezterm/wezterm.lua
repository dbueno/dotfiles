-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local appearance = require 'appearance'

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

if appearance.is_dark() then
  config.color_scheme = 'Tokyo Night'
else
  config.color_scheme = 'Tokyo Night Day'
end

-- Choose your favourite font, make sure it's installed on your machine
--config.font = wezterm.font({ family = 'IBM Plex Mono' })
-- And a font size that won't have you squinting
--config.font_size = 12

-- Slightly transparent and blurred background
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30

-- Keybindings
config.keys = {
  {
    key = 'Enter',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal {domain="CurrentPaneDomain"},
  },
  --{
  --  key = 'm',
  --  mods = 'CMD',
  --  action = wezterm.action.DisableDefaultAssignment,
  --},
}

-- and finally, return the configuration to wezterm
return config
