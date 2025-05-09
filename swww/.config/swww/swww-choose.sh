#!/usr/bin/bash
#start swww
WALLPAPERS_DIR=~/wallpaper/
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f | fzf --preview='kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {}')
swww img "$WALLPAPER"
