-- ###################
-- Every shortcut, in groups. Super is the main key. Apps (Super + a letter), the launcher, windows,
-- workspaces, the keyboard layout, screenshots, lock and leave, then the laptop's media keys.
-- Tools used here that later steps install: rofi, cliphist, grim + slurp, hyprlock, wpctl,
-- brightnessctl, playerctl
-- ###################

local super = "SUPER"
local key = function(mods, k) return mods .. " + " .. k end
local run = hl.dsp.exec_cmd

-- apps
hl.bind(key(super, "T"), run("ghostty"))           -- terminal
hl.bind(key(super, "B"), run("firefox"))           -- browser
hl.bind(key(super, "E"), run("nautilus --new-window"))   -- files
hl.bind(key(super, "N"), run("gnome-text-editor"))   -- notes (GNOME Text Editor)
hl.bind(key(super, "C"), run("gnome-calendar"))      -- calendar (GNOME Calendar)

-- the launcher, and clipboard history (pick something you copied earlier)
hl.bind(key(super, "A"), run("pkill -x rofi || rofi -show drun"))
hl.bind(key(super, "V"), run("pkill -x rofi || cliphist list | rofi -dmenu -p Clipboard | cliphist decode | wl-copy"))

-- windows: close, float, fullscreen, keep on top, split direction
hl.bind(key(super, "Q"), hl.dsp.window.close())
hl.bind(key(super, "F"), hl.dsp.window.fullscreen())
hl.bind(key(super .. " + SHIFT", "F"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key(super, "P"), hl.dsp.window.pin())
hl.bind(key(super, "J"), hl.dsp.layout("togglesplit"))
hl.bind("ALT + TAB", hl.dsp.window.cycle_next())

-- focus with Super + arrows; move the window with Super + Shift + arrows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(key(super, dir), hl.dsp.focus({ direction = dir }))
    hl.bind(key(super .. " + SHIFT", dir), hl.dsp.window.move({ direction = dir }))
end

-- Ctrl + Super + Left / Right: the previous / next workspace
hl.bind(key("CTRL + " .. super, "left"), hl.dsp.focus({ workspace = "r-1" }))
hl.bind(key("CTRL + " .. super, "right"), hl.dsp.focus({ workspace = "r+1" }))

-- workspaces: Super + 1…0 to go there, Super + Shift + 1…0 to send the window there;
-- Super + scroll to step through them
for i = 1, 10 do
    local k = tostring(i % 10)
    hl.bind(key(super, k), hl.dsp.focus({ workspace = i }))
    hl.bind(key(super .. " + SHIFT", k), hl.dsp.window.move({ workspace = i }))
end
hl.bind(key(super, "mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key(super, "mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

-- a scratchpad: a hidden workspace that slides over the others
hl.bind(key(super, "S"), hl.dsp.workspace.toggle_special("scratch"))
hl.bind(key(super .. " + SHIFT", "S"), hl.dsp.window.move({ workspace = "special:scratch" }))

-- drag windows with Super + left mouse, resize with Super + right mouse
hl.bind(key(super, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(key(super, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- keyboard layout: English (US) ⇄ Arabic
hl.bind(key(super, "K"), run("hyprctl switchxkblayout all next"))

-- screenshots: Print = an area, Shift + Print = the whole screen; both to the clipboard and
-- ~/Pictures/Screenshots
local shots = "mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png && "
hl.bind("PRINT", run("sh -c '" .. shots .. "grim -g \"$(slurp)\" \"$f\" && wl-copy < \"$f\"'"))
hl.bind("SHIFT + PRINT", run("sh -c '" .. shots .. "grim \"$f\" && wl-copy < \"$f\"'"))

-- lock, and leave Hyprland (a rare combination, so it can't happen by accident)
hl.bind(key(super, "L"), run("hyprlock"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exit())

-- the laptop's keys: volume, microphone, brightness, media (they work on the lock screen too)
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", run("brightnessctl set 5%+"), held)
hl.bind("XF86MonBrightnessDown", run("brightnessctl set 5%-"), held)
hl.bind("XF86AudioPlay", run("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", run("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", run("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", run("playerctl previous"), { locked = true })
