units = {
  right30       = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
  right70       = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
  left70        = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
  left30        = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 },
  left50        = { x = 0.00, y = 0.00, w = 0.4999, h = 1.00 },
  right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  -- i think x and y are the top-left of the desktop
  -- w is the width in pct
  left63        = { x = 0.00, y = 0.00, w = 0.62999, h = 1.00 },
  right37       = { x = 0.63, y = 0.00, w = 0.36999, h = 1.00 },
  -- these three can give me a layout of three windows by column
  left33        = { x = 0.00, y = 0.00, w = 0.32999, h = 1.00 },
  mid33         = { x = 0.33, y = 0.00, w = 0.32999, h = 1.00 },
  right33       = { x = 0.66, y = 0.00, w = 0.34, h = 1.00 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  upright30     = { x = 0.70, y = 0.00, w = 0.30, h = 0.50 },
  botright30    = { x = 0.70, y = 0.50, w = 0.30, h = 0.50 },
  upleft70      = { x = 0.00, y = 0.00, w = 0.70, h = 0.50 },
  botleft70     = { x = 0.00, y = 0.50, w = 0.70, h = 0.50 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 }
}

animationDuration = 0

-- bindings
--     'c'
-- 'j'    'l'
-- 'up'
-- 'down'

mash = { 'shift', 'ctrl', 'cmd' }
-- the n key in dvorak produces l
-- when i hit j, it produces h because of dvorak
hs.hotkey.bind(mash, 'h', function() hs.window.focusedWindow():move(units.left50,     nil, true) end)
hs.hotkey.bind(mash, 'n', function() hs.window.focusedWindow():move(units.right50,     nil, true) end)
-- 'u', 'i', and 'o' will layout three windows perfectly taking up a third of the screen, left-to-right
hs.hotkey.bind(mash, 'g', function() hs.window.focusedWindow():move(units.left33, nil, true) end)
hs.hotkey.bind(mash, 'c', function() hs.window.focusedWindow():move(units.mid33, nil, true) end)
hs.hotkey.bind(mash, 'r', function() hs.window.focusedWindow():move(units.right33, nil, true) end)
-- full screen
hs.hotkey.bind(mash, 't', function() hs.window.focusedWindow():move(units.maximum, nil, true) end)
-- the h key in dvorak produces d
-- hs.hotkey.bind(mash, 'd', function() hs.window.focusedWindow():move(units.left70,     nil, true) end)
-- hs.hotkey.bind(mash, 'k', function() hs.window.focusedWindow():move(units.top50,      nil, true) end)
-- hs.hotkey.bind(mash, 'j', function() hs.window.focusedWindow():move(units.bot50,      nil, true) end)
-- hs.hotkey.bind(mash, ']', function() hs.window.focusedWindow():move(units.upright30,  nil, true) end)
-- hs.hotkey.bind(mash, '[', function() hs.window.focusedWindow():move(units.upleft70,   nil, true) end)
-- hs.hotkey.bind(mash, ';', function() hs.window.focusedWindow():move(units.botleft70,  nil, true) end)
-- hs.hotkey.bind(mash, "'", function() hs.window.focusedWindow():move(units.botright30, nil, true) end)
-- hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.maximum,    nil, true) end)

hs.hotkey.bind(mash, "left", function()
  local win = hs.window.focusedWindow()
  local sz = win:size()
  sz.w = sz.w - 100
  win:setSize(sz)
end)
hs.hotkey.bind(mash, "right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 100
  win:setFrame(f)
end)
hs.hotkey.bind(mash, "up", function()
  local win = hs.window.focusedWindow()
  local sz = win:size()
  sz.h = sz.h - 100
  win:setSize(sz)
end)
hs.hotkey.bind(mash, "down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y + 100
  win:setFrame(f)
end)
-- Maximize the height of the window
-- hs.hotkey.bind(mash, "c", function()
--   local win = hs.window.focusedWindow()
--   local sz = win:size()
--   sz.h = win:screen():frame().h
--   win:setSize(sz)
-- end)

-- hs.hotkey.bind(mods, 'down', createMoveWindow(units.bottom))
-- hs.hotkey.bind(mods, 'left', createMoveWindow(units.left))
-- hs.hotkey.bind(mods, 'right', createMoveWindow(units.right))
-- hs.hotkey.bind(mods, 'up', createMoveWindow(units.top))
-- hs.hotkey.bind(mods, 'm', function()
--   hs.window.focusedWindow():maximize(animationDuration)
-- end)
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("config loaded")
