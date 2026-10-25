-- ###################
-- Eclipse: Adam's Hyprland setup. This file only loads the parts, in order; each one is short
-- and does one job. This computer's screens are in screen.lua
-- ###################

-- find the parts next to this file, wherever it's installed
local here = debug.getinfo(1, "S").source:match("^@(.*/)") or "./"
package.path = here .. "?.lua;" .. package.path

require("env")
require("look")
require("input")
require("keybinds")
require("rules")
require("autostart")
require("screen")
