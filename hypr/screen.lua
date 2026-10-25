-- ###################
-- This computer's screens. On another computer, change this file: its screen's name (see
-- `hyprctl monitors`), mode and scale. Any screen plugged in later gets its best mode
-- ###################

-- the laptop's own screen
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1.5 })
-- a plugged-in screen: its best mode, to the right
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
