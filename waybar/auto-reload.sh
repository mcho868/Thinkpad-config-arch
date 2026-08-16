while inotifywait -e close_write ~/.config/waybar; do killall -SIGUR2 waybar; done
