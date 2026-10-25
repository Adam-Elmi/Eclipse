#!/usr/bin/env bash
# ###################
# Eclipse installer. Installs packages.txt (pacman, asks for your password), backs up whatever it
# replaces in ~/.config into ~/.local/state/eclipse/backup-<date>/, links Eclipse's folders in
# their place, applies the GNOME settings, puts in the login screen (sudo), and checks the configs.
# Undo puts it all back.
#
#   ./install.sh                 install
#   ./install.sh --dry-run       show what it would do, change nothing
#   ./install.sh --no-packages   skip pacman (everything else as usual)
#   ./install.sh --undo          remove the links, restore the latest backup (files and settings)
# ###################
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE="$HOME/.local/state/eclipse"
DRY=0 PACKAGES=1 UNDO=0
for arg in "$@"; do
	case "$arg" in
		--dry-run) DRY=1 ;;
		--no-packages) PACKAGES=0 ;;
		--undo) UNDO=1 ;;
		*) echo "unknown option: $arg (see the top of install.sh)"; exit 2 ;;
	esac
done

say() { printf '\033[1;35m▸\033[0m %s\n' "$*"; }
run() { if [ "$DRY" = 1 ]; then echo "  would: $*"; else "$@"; fi; }

# what gets linked: <place in ~/.config> → <file or folder in the repo>
LINKS=(
	"hypr:hypr"
	"waybar:waybar"
	"rofi:launcher"
	"mako:mako"
	"ghostty:ghostty"
	"wlogout:wlogout"
	"xdg-desktop-portal/hyprland-portals.conf:portal/hyprland-portals.conf"
	"gtk-3.0/settings.ini:gtk/settings.ini"
	"gtk-4.0/settings.ini:gtk/settings.ini"
	"gtk-3.0/gtk.css:gtk/gtk3.css"
	"qt6ct:qt/qt6ct"
	"kdeglobals:qt/kdeglobals"
	"eclipse/wallpaper.png:theme/wallpaper.png"
	"eclipse/gtk-apply.sh:gtk/apply.sh"
	"uwsm/env-hyprland.d/00-eclipse.sh:uwsm/00-eclipse.sh"
)
# set aside, not replaced: HyDE starts Hyprland through uwsm with its own HYPRLAND_CONFIG, which
# would load HyDE's config whatever ~/.config/hypr holds. It goes into the backup; undo restores it
ASIDE=(
	"uwsm/env-hyprland.d/00-hyde.sh"
)
# the login screen: SDDM can't read your home, so the theme is copied (sudo); a file of its own
# selects it, read after any other sddm.conf.d file
SDDM_THEME=/usr/share/sddm/themes/eclipse
SDDM_CONF=/etc/sddm.conf.d/zz-eclipse.conf
# the GNOME settings gtk/apply.sh changes (saved first, so undo can put them back)
KEYS=(color-scheme accent-color gtk-theme font-name document-font-name monospace-font-name icon-theme cursor-theme)

# ###################
# Undo: the latest backup goes back; Eclipse's links go
# ###################
if [ "$UNDO" = 1 ]; then
	# the newest backup not used yet (used ones end in .undone)
	LAST="$(ls -1d "$STATE"/backup-* 2>/dev/null | grep -v '\.undone$' | tail -1 || true)"
	[ -n "$LAST" ] || { echo "No backup in $STATE: nothing to undo."; exit 1; }
	say "Undoing with $LAST"
	for pair in "${LINKS[@]}"; do
		place="$CONFIG/${pair%%:*}"
		if [ -L "$place" ] && [[ "$(readlink "$place")" == "$REPO"/* ]]; then run rm "$place"; fi
		if [ -e "$LAST/config/${pair%%:*}" ] || [ -L "$LAST/config/${pair%%:*}" ]; then
			run mkdir -p "$(dirname "$place")"
			run mv "$LAST/config/${pair%%:*}" "$place"
		fi
	done
	for entry in "${ASIDE[@]}"; do
		if [ -e "$LAST/config/$entry" ] && [ ! -e "$CONFIG/$entry" ]; then
			run mkdir -p "$(dirname "$CONFIG/$entry")"
			run mv "$LAST/config/$entry" "$CONFIG/$entry"
		fi
	done
	if [ -f "$LAST/gsettings" ]; then
		while read -r key value; do
			run gsettings set org.gnome.desktop.interface "$key" "$value"
		done < "$LAST/gsettings"
	fi
	if [ -e "$SDDM_CONF" ] || [ -d "$SDDM_THEME" ]; then
		say "Login screen: back to sddm's default (sudo)"
		run sudo rm -rf "$SDDM_CONF" "$SDDM_THEME"
	fi
	# folders the install made and that are now empty
	for dir in "$CONFIG/eclipse" "$CONFIG/gtk-4.0" "$CONFIG/gtk-3.0"; do
		[ -d "$dir" ] && [ -z "$(ls -A "$dir")" ] && run rmdir "$dir"
	done
	[ "$DRY" = 1 ] || mv "$LAST" "$LAST.undone"
	say "Done: your previous setup is back. Log out and in to use it."
	exit 0
fi

# ###################
# 1. Packages
# ###################
if [ "$PACKAGES" = 1 ]; then
	mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$REPO/packages.txt")
	# only what's missing: pacman -T also counts a package that provides it (an AUR -git build),
	# which pacman -S would otherwise offer to replace
	mapfile -t missing < <(pacman -T "${pkgs[@]}")
	if [ "${#missing[@]}" -gt 0 ]; then
		say "Installing packages (pacman asks for your password): ${missing[*]}"
		run sudo pacman -S --needed "${missing[@]}"
	else
		say "Packages: all installed"
	fi
fi

# ###################
# 2. Back up what's there, link Eclipse in its place
# ###################
# one backup holds the original setup until it's undone: running the installer again reuses it
# (so undo always brings back what was there before Eclipse, never an empty or Eclipse-made backup)
BACKUP="$(ls -1d "$STATE"/backup-* 2>/dev/null | grep -v '\.undone$' | tail -1 || true)"
[ -n "$BACKUP" ] || BACKUP="$STATE/backup-$(date +%Y-%m-%d_%H-%M-%S)"
say "Backing up into $BACKUP and linking Eclipse into $CONFIG"
run mkdir -p "$BACKUP/config"
for pair in "${LINKS[@]}"; do
	place="$CONFIG/${pair%%:*}"
	source="$REPO/${pair#*:}"
	if [ -L "$place" ] && [ "$(readlink "$place")" = "$source" ]; then
		echo "  already linked: ${pair%%:*}"
		continue
	fi
	if [ -e "$place" ] || [ -L "$place" ]; then
		kept="$BACKUP/config/${pair%%:*}"
		# never overwrite what the backup already holds: set this one aside next to it
		if [ -e "$kept" ] || [ -L "$kept" ]; then kept="$kept.$(date +%H%M%S)"; echo "  kept as well: $kept"; fi
		run mkdir -p "$(dirname "$kept")"
		run mv "$place" "$kept"
	fi
	run mkdir -p "$(dirname "$place")"
	run ln -s "$source" "$place"
	echo "  ${pair%%:*} → ${pair#*:}"
done

for entry in "${ASIDE[@]}"; do
	if [ -e "$CONFIG/$entry" ]; then
		run mkdir -p "$(dirname "$BACKUP/config/$entry")"
		run mv "$CONFIG/$entry" "$BACKUP/config/$entry"
		echo "  set aside: $entry"
	fi
done

# ###################
# 3. GNOME settings (saved first, for undo)
# ###################
say "GNOME apps: dark, rose accent, IBM Plex"
# only the first time: later runs would save Eclipse's own settings instead
if [ "$DRY" = 0 ] && [ ! -f "$BACKUP/gsettings" ]; then
	for key in "${KEYS[@]}"; do echo "$key $(gsettings get org.gnome.desktop.interface "$key")"; done > "$BACKUP/gsettings"
fi
run "$REPO/gtk/apply.sh"

# ###################
# 4. Login screen (SDDM): the Eclipse theme, copied fresh each time
# ###################
if [ -d /etc/sddm.conf.d ] || command -v sddm >/dev/null; then
	say "Login screen: Eclipse (sudo copies it into $SDDM_THEME)"
	run sudo rm -rf "$SDDM_THEME"
	run sudo cp -rL "$REPO/sddm/eclipse" "$SDDM_THEME"
	if [ "$DRY" = 1 ]; then echo "  would: write $SDDM_CONF (Current=eclipse)"; else
		printf '# Eclipse: the login screen theme (install.sh; --undo removes this file)\n[Theme]\nCurrent=eclipse\n' | sudo tee "$SDDM_CONF" >/dev/null
	fi
fi

# ###################
# 5. Checks
# ###################
say "Checking the configs"
if [ "$DRY" = 0 ]; then
	if Hyprland --verify-config -c "$CONFIG/hypr/hyprland.lua" 2>&1 | grep -q "config ok"; then echo "  Hyprland: ok"; else
		echo "  Hyprland: PROBLEM:"; Hyprland --verify-config -c "$CONFIG/hypr/hyprland.lua" 2>&1 | sed -n '/Config parsing result/,$p'; fi
	if command -v ghostty >/dev/null; then ghostty +validate-config >/dev/null 2>&1 && echo "  Ghostty: ok" || { echo "  Ghostty: PROBLEM:"; ghostty +validate-config || true; }; else echo "  Ghostty: not installed (skipped)"; fi
	rofi -dump-theme >/dev/null 2>&1 && echo "  rofi: ok" || echo "  rofi: PROBLEM (run: rofi -dump-theme)"
	# which config the next login loads: what uwsm's Hyprland files set last
	next="$(sh -c 'for f in "$1"/uwsm/env-hyprland "$1"/uwsm/env-hyprland.d/*.sh; do [ -f "$f" ] && . "$f"; done; echo "${HYPRLAND_CONFIG:-~/.config/hypr (default)}"' _ "$CONFIG" 2>/dev/null)"
	echo "  next login loads: $next"
	case "$next" in *hyprland.lua) ;; *) echo "  PROBLEM: that isn't Eclipse's config; something else sets HYPRLAND_CONFIG" ;; esac
fi

say "Done. Log out now, and log in to Hyprland: Eclipse starts. To go back: ./install.sh --undo"
# the session that's still running is the old one (HyDE): its files just moved into the backup
if [ "$DRY" = 0 ] && pgrep -x Hyprland >/dev/null; then
	echo "  Until you log out, the running session may show errors about its old files (for example"
	echo "  \"screen shader … no such file\"): they're the old setup missing its files, not Eclipse. Log out to clear them."
fi
