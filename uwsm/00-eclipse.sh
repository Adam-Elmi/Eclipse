#!/usr/bin/env sh
# ###################
# Eclipse's environment for Hyprland sessions started by uwsm (read before Hyprland starts):
# which config Hyprland loads, and Wayland for the toolkits that ask. install.sh links this into
# ~/.config/uwsm/env-hyprland.d/ (setting HyDE's own file aside in the backup)
# ###################

export HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"

export MOZ_ENABLE_WAYLAND=1                  # Firefox
export QT_QPA_PLATFORM="wayland;xcb"         # Qt apps: Wayland, X11 as a fallback
export QT_QPA_PLATFORMTHEME=qt6ct           # Qt apps: the Eclipse colors (qt/qt6ct)
export ELECTRON_OZONE_PLATFORM_HINT=auto     # Electron apps
