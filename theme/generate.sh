#!/usr/bin/env bash
# ###################
# Writes the Eclipse palette (theme/palette.sh) in each tool's format. The files it writes are
# kept in the repo, so installing never needs this; run it again after changing the palette
# ###################
set -euo pipefail
cd "$(dirname "$0")/.."
source theme/palette.sh
NOTE="Made by theme/generate.sh from theme/palette.sh; edit the palette, not this file"
names=(BG SURFACE PANEL HEADER LINE LINE_SOFT INK MUTED FAINT ACCENT ACCENT_HOVER PLUM SELECT OK WARN ERROR)
lower() { echo "$1" | tr 'A-Z' 'a-z'; }

# Hyprland (Lua): a module the other files require: local c = require("colors"); c.accent
{
	echo "-- $NOTE"
	echo "return {"
	for n in "${names[@]}"; do echo "    $(lower "$n") = \"rgb(${!n})\","; done
	echo "    font = \"$FONT\","
	echo "    mono = \"$MONO\","
	echo "}"
} > hypr/colors.lua

# hyprlock / hypridle / hyprpaper (hyprlang .conf): $accent = rgb(f06595), for `source =`
{
	echo "# $NOTE"
	for n in "${names[@]}"; do echo "\$$(lower "$n") = rgb(${!n})"; done
	echo "\$font = $FONT"
	echo "\$mono = $MONO"
} > hypr/eclipse-colors.conf

# mako (notifications): its whole config, since it has no include
{
	echo "# $NOTE"
	echo "font=$FONT $FONT_SIZE"
	echo "background-color=#${SURFACE}f0"
	echo "text-color=#${INK}"
	echo "border-color=#${ACCENT}66"
	echo "progress-color=over #${ACCENT}"
	echo "border-size=1"
	echo "border-radius=8"
	echo "padding=12,14"
	echo "margin=10"
	echo "width=360"
	echo "max-visible=4"
	echo "default-timeout=6000"
	echo "anchor=top-right"
	echo "icons=1"
	echo "max-icon-size=40"
	echo "format=<b>%s</b>\\n%b"
	echo
	echo "[urgency=low]"
	echo "text-color=#${MUTED}"
	echo
	echo "[urgency=critical]"
	echo "border-color=#${ERROR}"
	echo "default-timeout=0"
} > mako/config

# Waybar (GTK CSS): @define-color bg #282c33;
{
	echo "/* $NOTE */"
	for n in "${names[@]}"; do echo "@define-color $(lower "$n") #${!n};"; done
} > waybar/colors.css

# rofi: * { bg: #282c33; … }
{
	echo "/* $NOTE */"
	echo "* {"
	for n in "${names[@]}"; do echo "    $(lower "$n" | tr '_' '-'): #${!n};"; done
	echo "    font: \"$FONT $FONT_SIZE\";"
	echo "}"
} > launcher/colors.rasi

# Ghostty: a theme file
{
	echo "# $NOTE"
	echo "background = $BG"
	echo "foreground = $INK"
	echo "cursor-color = $ACCENT"
	echo "selection-background = $SELECT"
	echo "selection-foreground = $INK"
	for i in "${!ANSI[@]}"; do echo "palette = $i=#${ANSI[$i]}"; done
} > ghostty/themes/eclipse

# GTK 3 and 4 apps: dark, the font (the accent and dark mode for GTK 4 apps are gsettings, gtk/apply.sh)
{
	echo "# $NOTE"
	echo "[Settings]"
	echo "gtk-theme-name=adw-gtk3-dark"
	echo "gtk-application-prefer-dark-theme=1"
	echo "gtk-font-name=$FONT $FONT_SIZE"
} > gtk/settings.ini

# GTK 3 apps: the accent in rose (adw-gtk3 reads these names), linked as ~/.config/gtk-3.0/gtk.css
{
	echo "/* $NOTE */"
	echo "@define-color accent_color #${ACCENT};"
	echo "@define-color accent_bg_color #${ACCENT};"
	echo "@define-color accent_fg_color #ffffff;"
} > gtk/gtk3.css

# Qt apps (qt6ct): a color scheme, one #AARRGGBB per palette role, in Qt's order: window text,
# button, light, midlight, dark, mid, text, bright text, button text, base, window, shadow,
# highlight, highlighted text, link, visited link, alternate base, no role, tooltip base,
# tooltip text, placeholder text
qt_roles() { # $1: the color for text roles (normal or disabled)
	local t=$1
	echo "#ff$t, #ff$SURFACE, #ff$LINE, #ff$LINE_SOFT, #ff$HEADER, #ff$LINE, #ff$t, #ffffffff, #ff$t, #ff$BG, #ff$PANEL, #ff000000, #ff$SELECT, #ff$INK, #ff$ACCENT, #ff$PLUM, #ff$PANEL, #ff$BG, #ff$SURFACE, #ff$INK, #ff$FAINT"
}
{
	echo "# $NOTE"
	echo "[ColorScheme]"
	echo "active_colors=$(qt_roles "$INK")"
	echo "inactive_colors=$(qt_roles "$INK")"
	echo "disabled_colors=$(qt_roles "$FAINT")"
} > qt/qt6ct/colors/eclipse.conf

# KDE apps (Dolphin and friends) also read their colors from kdeglobals, as r,g,b
rgb() { printf '%d,%d,%d' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
kde_group() { # $1: group, $2: background, $3: alternate background
	echo "[Colors:$1]"
	echo "BackgroundNormal=$(rgb "$2")"
	echo "BackgroundAlternate=$(rgb "$3")"
	echo "ForegroundNormal=$(rgb "$INK")"
	echo "ForegroundInactive=$(rgb "$MUTED")"
	echo "ForegroundActive=$(rgb "$ACCENT")"
	echo "ForegroundLink=$(rgb "$ACCENT")"
	echo "ForegroundVisited=$(rgb "$PLUM")"
	echo "ForegroundNegative=$(rgb "$ERROR")"
	echo "ForegroundNeutral=$(rgb "$WARN")"
	echo "ForegroundPositive=$(rgb "$OK")"
	echo "DecorationFocus=$(rgb "$ACCENT")"
	echo "DecorationHover=$(rgb "$ACCENT_HOVER")"
	echo
}
{
	echo "# $NOTE"
	echo "[General]"
	echo "ColorScheme=EclipseNight"
	echo "font=$FONT,$FONT_SIZE,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
	echo "fixed=$MONO,$FONT_SIZE,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
	echo
	echo "[Icons]"
	echo "Theme=breeze-dark"
	echo
	echo "[KDE]"
	echo "widgetStyle=Breeze"
	echo
	kde_group View "$BG" "$PANEL"
	kde_group Window "$PANEL" "$BG"
	kde_group Button "$SURFACE" "$PANEL"
	kde_group Header "$HEADER" "$PANEL"
	kde_group Tooltip "$SURFACE" "$PANEL"
	kde_group Complementary "$HEADER" "$PANEL"
	kde_group Selection "$SELECT" "$SELECT"
} > qt/kdeglobals

# the login screen (SDDM): its theme.conf, which Main.qml reads as config.<name>
{
	echo "# $NOTE"
	echo "[General]"
	for n in "${names[@]}"; do echo "$(lower "$n")=#${!n}"; done
	echo "font=$FONT"
} > sddm/eclipse/theme.conf

echo "wrote hypr/colors.lua, hypr/eclipse-colors.conf, mako/config, waybar/colors.css, launcher/colors.rasi, ghostty/themes/eclipse, gtk/settings.ini, gtk/gtk3.css, qt/qt6ct/colors/eclipse.conf, qt/kdeglobals, sddm/eclipse/theme.conf"
