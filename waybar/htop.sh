#!/bin/sh
# ###################
# The bar's health click: htop in a small floating Ghostty; if it's already open, close it.
# Closed through Hyprland by its window class (Ghostty runs as two processes, so pkill misses one)
# ###################
c=dev.eclipse.htop
if hyprctl clients | grep -q "class: $c\$"; then
	hyprctl dispatch "hl.dsp.window.close({ window = \"class:^($c)\$\" })" >/dev/null
else
	exec ghostty --class=$c --title=htop -e htop
fi
