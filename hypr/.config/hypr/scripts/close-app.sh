# Enable debug output
set -x

# Get active window class and store it
active_window=$(hyprctl activewindow -j | jq -r ".class")
echo "Debug: Active window is '$active_window'"

# Check against multiple apps
case "$active_window" in
    "Steam" | "Discord" | "Spotify" | "tidal-hifi")
        echo "Debug: Minimizing $active_window"
        xdotool getactivewindow windowunmap
        ;;
    *)
        echo "Debug: Closing $active_window"
        hyprctl dispatch killactive ""
        ;;
esac

# Disable debug output
set +x

