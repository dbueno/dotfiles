--
-- dbueno's xmonad config, based on the sample.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import Data.List
import Data.Maybe
import XMonad
import System.Exit
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run( spawnPipe )
import System.IO

-- contrib
import XMonad.Actions.Commands
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.WindowBringer

import qualified Data.Map        as M
import qualified XMonad.StackSet as W

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "urxvt"
-- myTerminal = "xterm -fn -dec-terminal-medium-r-normal--14-140-75-75-c-80-iso8859-1"

-- Width of the window border in pixels.
--
myBorderWidth   = 3

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod3Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", emacsWSName, "10-todo"]

emacsWSName = "9-e-macs"

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
--myFocusedBorderColor = "#ff0000"
myFocusedBorderColor = "#a020f0"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
-- I changed all of them to hit the same key as before, only with dvorak.
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modMask,               xK_l     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- close focused window 
    , ((modMask .|. shiftMask, xK_j     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
--    , ((modMask,               xK_n     ), refresh)
    , ((modMask,               xK_b     ), refresh)

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    , ((mod1Mask,              xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
--    , ((modMask,               xK_j     ), windows W.focusDown)
    , ((modMask,               xK_h     ), windows W.focusDown)

    -- Move focus to the previous window
--     , ((modMask,               xK_k     ), windows W.focusUp  )
    , ((modMask,                xK_t     ), windows W.focusUp  )
    , ((mod1Mask .|. shiftMask, xK_Tab   ), windows W.focusUp  )

    -- Swap the focused window with the next window
--    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modMask .|. shiftMask, xK_h     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
--    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modMask .|. shiftMask, xK_t     ), windows W.swapUp    )

    -- Shrink the master area
--    , ((modMask,               xK_h     ), sendMessage Shrink)
    , ((modMask,               xK_d     ), sendMessage Shrink)

    -- Expand the master area
--    , ((modMask,               xK_l     ), sendMessage Expand)
    , ((modMask,               xK_n     ), sendMessage Expand)

    -- Push window back into tiling
--    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)
    , ((modMask,               xK_y     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
--    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask              , xK_w ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
--    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))
    , ((modMask              , xK_v), sendMessage (IncMasterN (-1)))

    -- toggle the status bar gap
    -- TODO, update this binding with avoidStruts , ((modMask              , xK_b     ),

    -- Quit xmonad
--    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modMask .|. shiftMask, xK_apostrophe     ), io (exitWith ExitSuccess))

    -- Restart xmonad
--    , ((modMask              , xK_q     ), restart "xmonad" True)
    , ((modMask              , xK_apostrophe     ), restart "xmonad" True)
    ]
    ++

    --
    -- mod-[1..0], Switch to workspace N
    -- mod-shift-[1..0], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- mod-e gives me my emacs workspace
    [((modMask, xK_e), windows $ W.greedyView
         (let ws = XMonad.workspaces conf
          in ws !! (fromJust $ elemIndex emacsWSName ws)))]

    ++
    -- WindowBringer
    [ ((modMask .|. shiftMask, xK_i), gotoMenu) ]
--    , ((modMask .|. shiftMask, xK_b), bringMenu) ]


    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
--     [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
--         | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
--         , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

    -- mod-ctrl 1 on WS 2 swaps WS 2 with 1.
    ++
    [((modMask .|. controlMask, k), windows $ swapWithCurrent i)
     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 ..]]

    -- For getting a menu of internal XMonad commands.
    ++
    [((modMask .|. shiftMask, xK_p), menuCommands >>= runCommand)]


-- commands for internal XMonad command menu
menuCommands :: X [(String, X())]
menuCommands = defaultCommands
--menuCommands = workspaceCommands


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList 

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

--     -- mod-button2, Raise the window to the top of the stack
--     , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

--     -- mod-button3, Set the window to floating mode and resize by dragging
     , ((modMask .|. shiftMask, button1), (\w -> focus w >> mouseResizeWindow w))

--     -- you may also bind events to the mouse scroll wheel (button4 and button5)
     ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = tiled ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--
myLogHook = return ()
-- myLogHook = dynamicLogDzen

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()
myStartupHook = spawn myTerminal

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "/usr/local/bin/xmobar /home/denbuen/.xmonad/xmobar"
    xmonad (defaults
            { logHook    = dynamicLogWithPP $
                           xmobarPP
                           { ppOutput = hPutStrLn xmproc
                           , ppTitle  = xmobarColor "green" "" . shorten 50 }
            , manageHook = manageDocks <+> manageHook defaults
            , layoutHook = avoidStruts  $  layoutHook defaults
            })
    

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will 
-- use the defaults defined in xmonad/XMonad/Config.hs
-- 
-- No need to modify this.
--
defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }


-- My helpers (DLB)
------------------------------------------------------------------------------

-- next: findByClass or window properties

emacsPred s = "emacs" `isInfixOf` s
           && not ("firefox" `isInfixOf` s)

-- | Focus on the first window for which the predicate returns `True'.
focusByName :: (String -> Bool) -> X ()
focusByName pred = do
    m <- windowMap -- WindowBringer
    case filter pred $ M.keys m of
      k:_ -> windows . W.focusWindow $ m ! k
      _   -> return ()
  where
    (!) = (M.!)
