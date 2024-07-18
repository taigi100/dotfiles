#!/bin/bash

selected_wallpaper=$(ls ~/dotfiles/wallpapers | wofi --dmenu)

if [ -n "$selected_wallpaper" ]; then
    hyprctl hyprpaper preload ~/dotfiles/wallpapers/"$selected_wallpaper"
    hyprctl hyprpaper wallpaper ,~/dotfiles/wallpapers/"$selected_wallpaper"
fi
