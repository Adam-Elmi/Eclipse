-- ###################
-- The Eclipse look: small gaps; the window you're in has a rose → plum border that slowly turns
-- and a faint rose glow (the others: a dim line, a plain shadow); small corners, blur behind
-- see-through windows (Ghostty), short calm animations. Colors from colors.lua
-- ###################

local c = require("colors")

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = { colors = { c.accent, c.plum, c.accent }, angle = 45 },
            inactive_border = c.line,
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding = 6,
        rounding_power = 2,
        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = "rgba(f0659538)",           -- the active window: a faint rose glow
            color_inactive = "rgba(00000080)",
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.2,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,    -- no Hyprland mascot wallpapers
        disable_hyprland_logo = true,
        background_color = c.bg,        -- behind the wallpaper, while it loads
    },
})

-- animations: one smooth curve, short times, nothing that bounces
hl.curve("eclipse", { type = "bezier", points = { {0.25, 1}, {0.3, 1} } })
hl.animation({ leaf = "global",      enabled = true, speed = 6,   bezier = "eclipse" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.5, bezier = "eclipse", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.5, bezier = "eclipse", style = "popin 92%" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "eclipse" })
hl.animation({ leaf = "border",      enabled = true, speed = 4,   bezier = "eclipse" })
-- the active border's gradient turns, once around every 10 s (the slowest Hyprland allows)
hl.curve("steady", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "steady", style = "loop" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3,   bezier = "eclipse", style = "slide" })
