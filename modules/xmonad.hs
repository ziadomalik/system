import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Util.EZConfig (additionalKeysP)

main :: IO ()
main = xmonad . ewmhFullscreen . ewmh $ def
	{ modMask     = mod4Mask
	, terminal    = "alacritty"
	, borderWidth = 2
	}
	`additionalKeysP`
	[ ("M-p", spawn "dmenu_run")
	]
