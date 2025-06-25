#!/usr/bin/env bash

# Directory where your wallpapers are stored
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Check if swww is running, if not, initialize it
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon
fi

while true; do
    # Find all image files in the directory
    WALLPAPERS=("$WALLPAPER_DIR"/*)

    # Select a random wallpaper
    RANDOM_WALLPAPER="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"

    # Set the wallpaper with a transition
    swww img "$RANDOM_WALLPAPER" \
        --transition-type "outer" \
        --transition-duration 3

    # Wait for a specified time before changing again (e.g., 15 minutes)
    sleep 900
done
