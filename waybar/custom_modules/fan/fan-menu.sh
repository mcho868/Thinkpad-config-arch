#!/usr/bin/env bash
# Safe fan control menu. Manual levels temporarily stop thinkfan; selecting
# automatic starts thinkfan again.
set -euo pipefail

FAN_PROC="/proc/acpi/ibm/fan"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

thinkfan_state="$(systemctl is-active thinkfan.service 2>/dev/null || true)"
current="$(awk -F'[:\t]+' '/^level/{print $2}' "$FAN_PROC" 2>/dev/null || true)"
[ -n "$current" ] || current="?"

menu=""
if [ "$thinkfan_state" = "active" ]; then
    menu+="●  Automatic (thinkfan)   current\n"
else
    menu+="○  Automatic (thinkfan)\n"
fi

for opt in auto 2 4 7; do
    case "$opt" in
        auto) label="Firmware automatic" ;;
        2) label="Level 2 · low" ;;
        4) label="Level 4 · medium" ;;
        7) label="Level 7 · max regulated" ;;
    esac

    if [ "$thinkfan_state" != "active" ] && [ "$opt" = "$current" ]; then
        menu+="●  ${label}   current\n"
    else
        menu+="○  ${label}\n"
    fi
done

choice="$(printf "%b" "$menu" | wofi --dmenu \
    --conf "$SCRIPT_DIR/wofi-config" \
    --style "$SCRIPT_DIR/../battery/wofi-style.css" \
    --prompt "Fan Control")"

[ -z "$choice" ] && exit 0

case "$choice" in
    *"Automatic (thinkfan)"*)
        pkexec systemctl start thinkfan.service
        ;;
    *"Firmware automatic"*)
        pkexec bash -c "systemctl stop thinkfan.service && echo 'level auto' > '$FAN_PROC'"
        ;;
    *"Level 2"*)
        pkexec bash -c "systemctl stop thinkfan.service && echo 'level 2' > '$FAN_PROC'"
        ;;
    *"Level 4"*)
        pkexec bash -c "systemctl stop thinkfan.service && echo 'level 4' > '$FAN_PROC'"
        ;;
    *"Level 7"*)
        pkexec bash -c "systemctl stop thinkfan.service && echo 'level 7' > '$FAN_PROC'"
        ;;
esac
