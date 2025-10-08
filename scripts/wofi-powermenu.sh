#!/usr/bin/env bash

# Wofi Power Menu
# A streamlined power menu for Hyprland

# Define the options
options="  Lock
  Logout
  Suspend
  Reboot
  Shutdown"

# Show wofi menu and get the selected option
chosen=$(echo -e "$options" | wofi \
    --dmenu \
    --prompt "Power" \
    --cache-file /dev/null \
    --width 200 \
    --height 230 \
    --location center \
    --hide-scroll \
    --no-actions \
    --matching fuzzy)

# Execute the corresponding action
case $chosen in
    "  Lock")
        swaylock
        ;;
    "  Logout")
        hyprctl dispatch exit
        ;;
    "  Suspend")
        systemctl suspend
        ;;
    "  Reboot")
        systemctl reboot
        ;;
    "  Shutdown")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
