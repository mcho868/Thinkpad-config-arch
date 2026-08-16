#!/bin/sh

set -eu

if makoctl mode 2>/dev/null | grep -Fxq 'do-not-disturb'; then
    makoctl mode -r do-not-disturb
else
    makoctl mode -a do-not-disturb
fi

# Refresh the custom module immediately instead of waiting for its interval.
pkill -RTMIN+9 -x waybar 2>/dev/null || true
