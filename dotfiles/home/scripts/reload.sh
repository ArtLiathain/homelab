#!/usr/bin/env bash
# Wallust hook script — refresh Waybar + Hyprpaper after wallpaper/color change

# Kill Hyprpaper to clear current wallpaper
pkill hyprpaper 2>/dev/null

# Restart Hyprpaper with the Hyprland dispatcher
hyprctl dispatch exec hyprpaper &
makoctl reload
# Reload Waybar (SIGUSR2 makes Waybar reload its config and style)
# pkill -SIGUSR2 waybar 2>/dev/null

echo "✅ Wallust hook: Hyprpaper restarted and Waybar refreshed."
