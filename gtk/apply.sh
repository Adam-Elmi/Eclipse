#!/usr/bin/env bash
# ###################
# The GNOME apps (Nautilus, Loupe, Papers, Text Editor) read dark mode, the accent and the fonts from
# these settings. install.sh runs this; it changes only these keys
# ###################
set -euo pipefail
# the real file, not the link in ~/.config/eclipse (the palette sits next to it in the repo)
here="$(dirname "$(readlink -f "$0")")"
source "$here/../theme/palette.sh"
s="gsettings set org.gnome.desktop.interface"
$s color-scheme prefer-dark
$s accent-color pink          # GNOME's accents are named; pink is the rose
$s gtk-theme adw-gtk3-dark    # GTK 3 apps (Network Connections, Blueman): has no built-in dark Adwaita
$s font-name "$FONT $FONT_SIZE"
$s document-font-name "$FONT $FONT_SIZE"
$s monospace-font-name "$MONO $FONT_SIZE"
$s icon-theme Adwaita         # GNOME's own icons, matching the apps
$s cursor-theme Adwaita
echo "GNOME apps: dark, rose accent, $FONT, Adwaita icons"
