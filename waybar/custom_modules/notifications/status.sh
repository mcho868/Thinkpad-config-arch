#!/bin/sh

set -eu

if makoctl mode 2>/dev/null | grep -Fxq 'do-not-disturb'; then
    text='󰂛'
    class='muted'
    tooltip='Notifications silenced — click to restore'
else
    text='󰂚'
    class='enabled'
    tooltip='Notifications enabled — click to silence'
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$tooltip"
