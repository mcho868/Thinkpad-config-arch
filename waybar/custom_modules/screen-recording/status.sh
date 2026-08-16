#!/bin/sh

runtime_directory="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pid_file="$runtime_directory/rbdd-wf-recorder.pid"
started_file="$runtime_directory/rbdd-wf-recorder.started"

[ -r "$pid_file" ] || exit 0
recorder_pid="$(cat "$pid_file")"
kill -0 "$recorder_pid" 2>/dev/null || exit 0

started="$(cat "$started_file" 2>/dev/null)"
case "$started" in
    ''|*[!0-9]*) started="$(date +%s)" ;;
esac

elapsed=$(( $(date +%s) - started ))
printf '● REC %02d:%02d\n' $((elapsed / 60)) $((elapsed % 60))
