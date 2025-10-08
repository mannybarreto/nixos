#!/usr/bin/env bash

# Wofi Window Switcher for Hyprland
# Lists all windows and allows switching to them with icons

# Get all windows from Hyprland
get_windows() {
    hyprctl clients -j | jq -r '.[] |
        "\(.workspace.name):\(.class):\(.title):\(.address)"' |
        while IFS=':' read -r ws class title addr; do
            # Truncate long titles
            if [ ${#title} -gt 50 ]; then
                title="${title:0:47}..."
            fi

            # Map installed applications to icons
            icon=""
            case "${class,,}" in
                *chromium*) icon=" " ;;
                *wezterm*) icon=" " ;;
                *code*|*vscode*) icon=" " ;;
                *zed*) icon=" " ;;
                *vim*|*nvim*) icon=" " ;;
                *rider*) icon=" " ;;
                *godot*) icon=" " ;;
                *gimp*) icon=" " ;;
                *mpv*) icon=" " ;;
                *discord*) icon=" " ;;
                *steam*) icon=" " ;;
                *lutris*) icon=" " ;;
                *obs*) icon=" " ;;
                *btop*) icon=" " ;;
                *pavucontrol*) icon=" " ;;
                *mc|*midnight*) icon=" " ;;
                *wofi*) icon=" " ;;
                *waybar*) icon=" " ;;
                *makemkv*) icon=" " ;;
                *) icon=" " ;;
            esac

            # Format: Icon App [Workspace] Title
            echo -e "${icon} ${class} [${ws}] ${title}|${addr}"
        done
}

# Show wofi menu and get selection
selected=$(get_windows | cut -d'|' -f1 | wofi \
    --dmenu \
    --prompt "Switch Window" \
    --cache-file /dev/null \
    --width 700 \
    --height 400 \
    --location center \
    --matching fuzzy \
    --insensitive \
    --allow-markup)

# If something was selected, switch to that window
if [ -n "$selected" ]; then
    # Get the address from the original list
    addr=$(get_windows | grep -F "$selected" | cut -d'|' -f2 | head -n1)

    if [ -n "$addr" ]; then
        # Focus the window
        hyprctl dispatch focuswindow "address:${addr}"
    fi
fi
