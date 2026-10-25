-- ###################
-- What starts with Hyprland: the bar, notifications, the wallpaper, idle (dim / lock / screen
-- off), the password prompt for admin actions, and the clipboard history
-- ###################

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")                                   -- the bar
    hl.exec_cmd("mako")                                     -- notifications
    hl.exec_cmd("hyprpaper")                                -- the wallpaper
    hl.exec_cmd("hypridle")                                 -- dim, lock, screen off when idle
    hl.exec_cmd("systemctl --user start hyprpolkitagent")   -- password prompts for admin actions
    -- clipboard history: remember text and pictures you copy (Super+V lists them)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- the GNOME apps take Eclipse's dark mode, accent and fonts (gtk/apply.sh, installed next to this file)
    hl.exec_cmd("sh -c '[ -x \"$HOME/.config/eclipse/gtk-apply.sh\" ] && \"$HOME/.config/eclipse/gtk-apply.sh\"'")
end)
