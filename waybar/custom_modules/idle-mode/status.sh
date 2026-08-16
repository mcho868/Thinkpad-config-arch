#!/usr/bin/env bash

set -u

readonly HELPER="${HOME}/.config/waybar/custom_modules/idle-mode/idle-mode.sh"
mode="$($HELPER status 2>/dev/null || printf '%s' 10m)"

case "$mode" in
    never)
        label='Never'
        class='never'
        tooltip='Idle lock disabled — right-click to choose a timeout'
        ;;
    10m)
        label='10m'
        class='ten'
        tooltip='Locks after 10 minutes of inactivity'
        ;;
    20m)
        label='20m'
        class='twenty'
        tooltip='Locks after 20 minutes of inactivity'
        ;;
    30m)
        label='30m'
        class='thirty'
        tooltip='Locks after 30 minutes of inactivity'
        ;;
    60m)
        label='60m'
        class='sixty'
        tooltip='Locks after 60 minutes of inactivity'
        ;;
    *)
        label='10m'
        class='ten'
        tooltip='Locks after 10 minutes of inactivity'
        ;;
esac

if [[ "${WAYBAR_VERTICAL:-0}" == '1' ]]; then
    text="󰌾\\n${label}"
else
    text="󰌾 ${label}"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
