#!/bin/sh

runtime_directory="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pid_file="$runtime_directory/rbdd-wf-recorder.pid"

if [ -r "$pid_file" ]; then
    recorder_pid="$(cat "$pid_file")"
    if kill -0 "$recorder_pid" 2>/dev/null; then
        exec "$HOME/.local/bin/wayland-screen-record"
    fi
fi

exec chromium --app=https://calendar.google.com
