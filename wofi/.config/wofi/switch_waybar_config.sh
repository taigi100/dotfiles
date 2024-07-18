#!/bin/bash

CONFIG_DIR="$HOME/.config/waybar"
CONFIGS_DIR="$CONFIG_DIR/configs"
STYLES_DIR="$CONFIG_DIR/style"
# Function to select file using wofi
select_file() {
    local dir=$1
    local prompt=$2
    ls "$dir" | wofi --dmenu --prompt="$prompt"
}

# Select config
config=$(select_file "$CONFIGS_DIR" "Select Waybar config:")
if [ -n "$config" ]; then
    ln -sf "$CONFIGS_DIR/$config" "$CONFIG_DIR/config"
fi

# Select style
style=$(select_file "$STYLES_DIR" "Select Waybar style:")
if [ -n "$style" ]; then
    ln -sf "$STYLES_DIR/$style" "$CONFIG_DIR/style.css"
fi

# Restart Waybar if either config or style was changed
if [ -n "$config" ] || [ -n "$style" ]; then
    pkill waybar
    waybar &
fi
