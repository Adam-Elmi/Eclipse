-- ###################
-- Keyboard and touchpad: English (US) and Arabic layouts (the key to switch is in keybinds.lua),
-- focus follows the mouse, tap to click, three fingers sideways to change workspace
-- ###################

hl.config({
    input = {
        kb_layout = "us,ara",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
