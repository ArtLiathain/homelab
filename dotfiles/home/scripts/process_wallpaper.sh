wall_selection="$1"
[[ -n "$wall_selection" ]] || { echo "Usage: $0 <wallpaper-image>"; exit 1; }
[[ -f "$wall_selection" ]] || { echo "File not found: $wall_selection"; exit 1; }


converted_cache_dir="${HOME}/.cache/converted_wallpapers/"

# Set the wallpaper with waypaper
[[ -n "$wall_selection" ]] || exit 1
# Create cache dir if not exists
if [ ! -d "${converted_cache_dir}" ] ; then
        mkdir -p "${converted_cache_dir}"
fi
wallpaper_name="active_wallpaper.${wall_selection##*.}"
magick ${wall_dir}${wall_selection} -resize 1920x1080^ -gravity center -extent 1920x1080 -quality 90 ${converted_cache_dir}${wallpaper_name}
wallust run -s ${converted_cache_dir}${wallpaper_name}

