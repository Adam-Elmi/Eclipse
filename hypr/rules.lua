-- ###################
-- Window rules: apps can't make themselves maximized behind your back, and small helper windows
-- (file pickers, the password prompt) float in the middle instead of taking a tile. The launcher,
-- notifications and the power menu are dark glass: Hyprland blurs what's behind them
-- ###################

hl.window_rule({
    name = "no-surprise-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "dialogs-float",
    match = { class = "^(xdg-desktop-portal-gtk|hyprpolkitagent)$" },
    float = true,
    center = true,
})

-- the bar's windows (Wi-Fi's Edit Connections and password prompts, Blueman, htop): small
-- floating windows in the middle
hl.window_rule({
    name = "bar-popups-float",
    match = { class = "^(nm-connection-editor|nm-applet|\\.?blueman-manager.*|dev\\.eclipse\\.htop)$" },
    float = true,
    center = true,
    size = "760 520",
})

hl.layer_rule({
    name = "glass",
    match = { namespace = "^(rofi|notifications|logout_dialog)$" },
    blur = true,
    ignore_alpha = 0.01,    -- not the see-through corners
})
