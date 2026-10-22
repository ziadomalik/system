--------------------------------------------------------------------------------
-- File   : ~/.xmonad/xmonad.hs                                               --
-- Author : Xiaokui Shu                                                       --
--                                                                            --
-- Xmonad : 0.18.0                                                            --
-- Update : 18.10.2026                                                        --
--                                                                            --
-- Multi-Screen (Multi-Head) Behavior                                         --
--   | start with only one screen       : ws#1 on screen 0                    --
--   | start with multi-screens         : ws#i on screen i | i <- [0..]       --
--   | rescreen from one to two screens : ws#g on the 2nd screen              --
--   where                                                                    --
--     workspaces = [ws#0 .. ws#9, ws#g]                                      --
--     shiftkeys  = [xK_0 .. xK_9, xK_grave]                                  --
--     ws#g (usually empty) is the reserved workspace for the 2nd screen      --
--                                                                            --
-- Additional Window Management                                               --
--   | modMask + g => list existing windows for switching                     --
--   | modMask + c => start a floating console                                --
--                                                                            --
-- Additional Shortcut                                                        --
--   |         xF86XK_Display => detect/set external minitors                 --
--   | Shfit + xF86XK_Display => mirror external minitors                     --
--   | Ctrl  + xF86XK_Display => turn off external minitors                   --
--   |         xF86XK_Time    => show time and date                           --
--                                                                            --
-- Screenshot Shortcut                                                        --
--   | modMask + Shift + s   => flameshot annotation GUI                      --
--------------------------------------------------------------------------------

import Data.Map (Map)
import Control.Monad (when)
import Data.Time.LocalTime (getZonedTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import Control.Concurrent (threadDelay)
import Graphics.X11.ExtraTypes.XF86 ( xF86XK_MonBrightnessUp
                                    , xF86XK_MonBrightnessDown
                                    , xF86XK_AudioMute
                                    , xF86XK_AudioRaiseVolume
                                    , xF86XK_AudioLowerVolume
                                    , xF86XK_Display
                                    , xF86XK_Time
                                    )

import XMonad
import qualified XMonad.StackSet as W

import XMonad.Util.CustomKeys (customKeys)
import XMonad.Layout.IndependentScreens (countScreens)
import XMonad.Actions.Warp (warpToScreen)
import XMonad.Actions.WindowBringer (gotoMenu)
import XMonad.Util.WindowProperties (Property (Role), propertyToQuery)
import XMonad.Util.XUtils ( showSimpleWindow
                          , deleteWindow
                          , WindowConfig(WindowConfig)
                          , WindowRect(CenterWindow)
                          )
import XMonad.Hooks.ManageHelpers (doRectFloat)
import XMonad.Hooks.BorderPerWindow (defineBorderWidth, actionQueue)

import Control.Exception (try, IOException)
import Data.Char (isSpace)

--------------------------------------------------------------------------------
-- MAIN                                                                       --
--------------------------------------------------------------------------------

myModMask :: KeyMask
myModMask = mod1Mask

myTerminal :: String
myTerminal = "alacritty"

fconsoleName :: String
fconsoleName = "fconsole"

floatingConsole :: String
floatingConsole =  myTerminal
                ++ " --title " ++ fconsoleName
                ++ " -e bash --rcfile ~/.bashrc_console"

main :: IO ()
main = do
    screenCnt <- countScreens
    xmonad $ actionQueue $ def
        { normalBorderColor     = "#222222"
        , focusedBorderColor    = "#535d6c"
        , terminal              = myTerminal
        , layoutHook            = myLayout
        , manageHook            = myManageHook
        , workspaces            = myWorkspaces
        , modMask               = myModMask
        , keys                  = myKeyMaps
        , borderWidth           = 4
        , startupHook           = myStartupHook screenCnt
        }

--------------------------------------------------------------------------------
-- Workspaces                                                                 --
--------------------------------------------------------------------------------

wsidToName :: (Integral i, Show i) => i -> String
wsidToName i
    | i >= 0 && i <= 9  = "ws#" ++ show i
    | i == 10           = "ws#g"
    | otherwise         = "ws#e"

-- special workspaces for new screen handling
wsZero :: String
wsZero  = wsidToName 0

wsOne :: String
wsOne   = wsidToName 1

wsGrave :: String
wsGrave = wsidToName 10

myWorkspaces :: [String]
myWorkspaces = map wsidToName [0 .. 10]

myWorkspaceKeys :: [KeySym]
myWorkspaceKeys = [xK_0 .. xK_9] ++ [xK_grave]

--------------------------------------------------------------------------------
-- Layout Settings                                                            --
--------------------------------------------------------------------------------

myLayout = Tall 1 (3/100) (1/2) ||| Mirror (Tall 1 (3/100) (1/2))

--------------------------------------------------------------------------------
-- Key Map Changes                                                          --
--------------------------------------------------------------------------------

myKeyMaps :: XConfig Layout -> Map (KeyMask, KeySym) (X ())
myKeyMaps = customKeys (\_ -> removedKeyMaps) (\_ -> insertedKeyMaps)

removedKeyMaps :: [(KeyMask, KeySym)]
removedKeyMaps =  defaultWorkspaceKeyMap
               ++ defaultScreenKeyMap
               ++ defaultOpKeyMap

insertedKeyMaps :: [((KeyMask, KeySym), X ())]
insertedKeyMaps =  myWorkspaceKeyMap
                ++ myScreenKeyMap
                ++ myOpKeyMap
                ++ myShortcutKeyMap
                ++ myScreenshotKeyMap


defaultWorkspaceKeyMap :: [(KeyMask, KeySym)]
defaultWorkspaceKeyMap =
    [(m .|. mod1Mask, n) | n <- [xK_1 .. xK_9], m <- [0, shiftMask]]

myWorkspaceKeyMap :: [((KeyMask, KeySym), X ())]
myWorkspaceKeyMap =
    [((m .|. myModMask, k), windows $ f i)
        | (i, k) <- zip myWorkspaces myWorkspaceKeys
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

defaultScreenKeyMap :: [(KeyMask, KeySym)]
defaultScreenKeyMap =
    [(m .|. mod1Mask, n) | n <- [xK_w, xK_e, xK_r], m <- [0, shiftMask]]

myScreenKeyMap :: [((KeyMask, KeySym), X ())]
myScreenKeyMap =
    [ ( (m .|. myModMask, key), do
        ws <- screenWorkspace sc
        whenJust ws (windows . f)
        warpToScreen sc 0.618 0.618 -- additional mouse operation
      )
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
    ]

defaultOpKeyMap :: [(KeyMask, KeySym)]
defaultOpKeyMap =
    [ (mod1Mask                 , xK_Return)
    , (mod1Mask .|. shiftMask   , xK_Return)
    , (mod1Mask                 , xK_p)
    ]

myOpKeyMap :: [((KeyMask, KeySym), X ())]
myOpKeyMap =
    [ ((myModMask               , xK_Return), spawn myTerminal)
    , ((myModMask .|. shiftMask , xK_Return), windows W.swapMaster)
    , ((myModMask               , xK_c), spawn floatingConsole)
    , ((myModMask               , xK_d), spawn "dmenu_run")
    , ((myModMask               , xK_g), gotoMenu)
    , ((myModMask               , xK_r), fclock)
    ] 

myScreenshotKeyMap :: [((KeyMask, KeySym), X ())]
myScreenshotKeyMap =
    [  ((myModMask .|. shiftMask  , xK_s)    , spawn "flameshot gui") ]

myShortcutKeyMap :: [((KeyMask, KeySym), X ())]
myShortcutKeyMap =
    [ ((noModMask,   xF86XK_MonBrightnessUp)  , spawn "xbacklight -inc 10")
    , ((noModMask,   xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
    , ((noModMask,   xF86XK_AudioMute)        , spawn "amixer set Master toggle")
    , ((noModMask,   xF86XK_AudioRaiseVolume) , spawn "amixer set Master 2%+")
    , ((noModMask,   xF86XK_AudioLowerVolume) , spawn "amixer set Master 2%-")
    , ((noModMask,   xF86XK_Display)          , rescreenExt)
    , ((shiftMask,   xF86XK_Display)          , rescreenMir)
    , ((controlMask, xF86XK_Display)          , rescreenNoE)
    , ((noModMask,   xF86XK_Time)             , fclock)
    ]

--------------------------------------------------------------------------------
-- Multi-Screen                                                               --
--------------------------------------------------------------------------------

cmdXrandrExt :: String
cmdXrandrExt = "~/.config/xmonad/displaymgt.sh"

cmdXrandrMir :: String
cmdXrandrMir = "~/.config/xmonad/displaymgt.sh --mirror"

cmdXrandrNoE :: String
cmdXrandrNoE = "~/.config/xmonad/displaymgt.sh --noext"

rescreenExt :: X ()
rescreenExt = do
    wsCurrent <- gets (W.currentTag . windowset)
    windows $ W.greedyView wsGrave
    windows $ W.greedyView wsCurrent
    spawn   $ cmdXrandrExt ++ ";"

rescreenMir :: X ()
rescreenMir = spawn $ cmdXrandrMir ++ ";" 

rescreenNoE :: X ()
rescreenNoE = spawn $ cmdXrandrNoE ++ ";" 

--------------------------------------------------------------------------------
-- Composition Settings                                                       --
--------------------------------------------------------------------------------

myManageHook :: ManageHook
myManageHook = composeAll
    [ title =? fconsoleName
        --> doRectFloat (W.RationalRect 0.618 0.68 0.26 0.26)
 
    -- resize and float all dialog window
    , propertyToQuery (Role "GtkFileChooserDialog")
        --> doRectFloat (W.RationalRect 0.25 0.25 0.5 0.5)
    
    -- no border for following windows
    -- use `xprop` to find window className
    , className =? "mpv" --> defineBorderWidth 0
    , title     =? fconsoleName --> defineBorderWidth 2
    , className =? "flameshot" --> doFloat
    , className =? "flameshot" --> defineBorderWidth 0
    ]

--------------------------------------------------------------------------------
-- Floating Clock                                                             --
--------------------------------------------------------------------------------

fclock :: X ()
fclock = do
    t <- liftIO clockString
    w <- showSimpleWindow clockWindowConfig [t]
    refresh
    liftIO $ threadDelay 1000000
    deleteWindow w

clockWindowConfig :: WindowConfig
clockWindowConfig =
    WindowConfig "xft:monospace-18" "black" "white" CenterWindow

clockString :: IO String
clockString = do
    t   <- getZonedTime
    bat <- batteryString
    return $ formatTime defaultTimeLocale " %r | %b %d" t ++ " | " ++ bat ++ " "

batteryString :: IO String
batteryString = do
    cap <- readSys "/sys/class/power_supply/BAT0/capacity"
    st  <- readSys "/sys/class/power_supply/BAT0/status"
    return $ case (cap, st) of
        (Just c, Just "Charging") -> c ++ "% (charging)"
        (Just c, _)               -> c ++ "%"
        _                         -> "no battery"

-- Read a sysfs file 
readSys :: FilePath -> IO (Maybe String)
readSys p = either (const Nothing) Just <$>
    (try (do s <- readFile p
             length s `seq` return (takeWhile (not . isSpace) s))
        :: IO (Either IOException String))

--------------------------------------------------------------------------------
-- Auto Startup                                                               --
--------------------------------------------------------------------------------

myStartupHook :: (Integral i) => i -> X ()
myStartupHook scrCnt = do
    spawn "xset s off -dpms"
    spawn "xsetroot -cursor_name left_ptr"
    spawn "xrandr --output DP-0 --primary --auto --output HDMI-0 --auto --right-of DP-0"

    when (scrCnt == 1) (windows $ W.greedyView wsOne)
