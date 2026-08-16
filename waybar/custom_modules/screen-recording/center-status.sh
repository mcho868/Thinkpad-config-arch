#!/bin/sh

runtime_directory="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pid_file="$runtime_directory/rbdd-wf-recorder.pid"
started_file="$runtime_directory/rbdd-wf-recorder.started"

if [ -r "$pid_file" ]; then
    recorder_pid="$(cat "$pid_file")"
    if kill -0 "$recorder_pid" 2>/dev/null; then
        started="$(cat "$started_file" 2>/dev/null)"
        case "$started" in
            ''|*[!0-9]*) started="$(date +%s)" ;;
        esac

        elapsed=$(( $(date +%s) - started ))
        printf '{"text":"● REC %02d:%02d","class":"recording","tooltip":"Screen recording — click to stop"}\n' \
            $((elapsed / 60)) $((elapsed % 60))
        exit 0
    fi
fi

printf '{"text":"󰥔 %s","class":"clock","tooltip":"Click to open Google Calendar"}\n' \
    "$(date '+%a, %d. %b %I:%M %p')"
