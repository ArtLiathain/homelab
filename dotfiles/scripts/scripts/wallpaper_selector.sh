#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#	
#	Heavily inspired by:  develcooking - https://github.com/develcooking/hyprland-dotfiles	
# Info    - This script runs the rofi launcher, to select
#             the wallpapers included in the theme you are in.

# Set some variables
wall_dir="${HOME}/Documents/wallpapers/"
cache_dir="${HOME}/.cache/thumbnails/wal_selector"
converted_cache_dir="${HOME}/.cache/converted_wallpapers/"
rofi_config_path="${HOME}/.config/rofi/rofi-wallpaper-sel.rasi"
rofi_command="rofi -dmenu -config ${rofi_config_path} -theme-str ${rofi_override}"

# Create cache dir if not exists
if [ ! -d "${cache_dir}" ] ; then
        mkdir -p "${cache_dir}"
fi

# Convert images in directory and save to cache dir
for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$imagen" ]; then
		filename=$(basename "$imagen")
			if [ ! -f "${cache_dir}/${filename}" ] ; then
				magick convert -strip "$imagen" -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_dir}/${filename}"
			fi
    fi
done

# Select a picture with rofi
wall_selection=$(
    find "${wall_dir}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -printf '%f\n' | sort | while read -r A; do
        printf "%s\x00icon\x1f%s/%s\n" "$A" "$cache_dir" "$A"
    done | $rofi_command
)

# Set the wallpaper with waypaper
[[ -n "$wall_selection" ]] || exit 1
# Create cache dir if not exists
if [ ! -d "${converted_cache_dir}" ] ; then
        mkdir -p "${converted_cache_dir}"
fi
wallpaper_name="active_wallpaper.${wall_selection##*.}"
magick ${wall_dir}${wall_selection} -resize 1920x1080^ -gravity center -extent 1920x1080 -quality 90 ${converted_cache_dir}${wallpaper_name}
wallust run -s ${converted_cache_dir}${wallpaper_name}
source "${HOME}/scripts/reload.sh"
exit 0

