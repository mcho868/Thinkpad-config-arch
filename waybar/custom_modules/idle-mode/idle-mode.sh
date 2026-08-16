#!/usr/bin/env bash

set -euo pipefail

readonly TEMPLATE="${HOME}/.config/hypr/hypridle-mode.template.conf"
readonly ACTIVE_CONFIG="${HOME}/.config/hypr/hypridle-active.conf"
readonly STATE_FILE="${HOME}/.local/state/waybar-idle-mode"
readonly WAYBAR_SIGNAL=10

valid_mode() {
    case "${1:-}" in
        never|10m|20m|30m|60m) return 0 ;;
        *) return 1 ;;
    esac
}

current_mode() {
    local mode=""
    if [[ -r "$STATE_FILE" ]]; then
        IFS= read -r mode < "$STATE_FILE" || true
    fi
    if valid_mode "$mode"; then
        printf '%s\n' "$mode"
    else
        printf '%s\n' '10m'
    fi
}

mode_values() {
    case "$1" in
        never)
            # Ten years is effectively disabled while keeping hypridle's
            # timeout parser on a normal positive value. Manual suspend and
            # lid-close still run before_sleep_cmd and lock the session.
            LOCK_TIMEOUT=315360000
            SUSPEND_TIMEOUT=315360000
            ;;
        10m)
            LOCK_TIMEOUT=600
            SUSPEND_TIMEOUT=1800
            ;;
        20m)
            LOCK_TIMEOUT=1200
            SUSPEND_TIMEOUT=2400
            ;;
        30m)
            LOCK_TIMEOUT=1800
            SUSPEND_TIMEOUT=3600
            ;;
        60m)
            LOCK_TIMEOUT=3600
            SUSPEND_TIMEOUT=7200
            ;;
        *)
            return 1
            ;;
    esac
}

write_state() {
    local mode="$1"
    local tmp="${STATE_FILE}.tmp.$$"
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$mode" > "$tmp"
    mv -f "$tmp" "$STATE_FILE"
}

refresh_waybar() {
    pkill -RTMIN+"$WAYBAR_SIGNAL" -x waybar 2>/dev/null || true
}

apply_mode() {
    local mode="$1"
    local tmp="${ACTIVE_CONFIG}.tmp.$$"

    valid_mode "$mode" || {
        printf 'Unknown idle mode: %s\n' "$mode" >&2
        exit 2
    }
    mode_values "$mode"

    sed \
        -e "s/@LOCK_TIMEOUT@/${LOCK_TIMEOUT}/" \
        -e "s/@SUSPEND_TIMEOUT@/${SUSPEND_TIMEOUT}/" \
        "$TEMPLATE" > "$tmp"
    mv -f "$tmp" "$ACTIVE_CONFIG"
    write_state "$mode"

    systemctl --user restart hypridle.service
    refresh_waybar
}

choose_menu() {
    local choice
    choice="$(printf '%s\n' \
        'Never — no automatic lock or suspend' \
        '10 minutes' \
        '20 minutes' \
        '30 minutes' \
        '60 minutes' | \
        wofi --dmenu --prompt 'Idle timeout' \
            --conf "${HOME}/.config/waybar/custom_modules/battery/wofi-config" \
            --style "${HOME}/.config/waybar/custom_modules/battery/wofi-style.css" || true)"

    case "$choice" in
        *Never*) apply_mode never ;;
        *10\ minutes*) apply_mode 10m ;;
        *20\ minutes*) apply_mode 20m ;;
        *30\ minutes*) apply_mode 30m ;;
        *60\ minutes*) apply_mode 60m ;;
    esac
}

next_mode() {
    case "$(current_mode)" in
        never) apply_mode 10m ;;
        10m) apply_mode 20m ;;
        20m) apply_mode 30m ;;
        30m) apply_mode 60m ;;
        60m) apply_mode never ;;
    esac
}

case "${1:-next}" in
    status)
        current_mode
        ;;
    next)
        next_mode
        ;;
    menu)
        choose_menu
        ;;
    set)
        apply_mode "${2:-}"
        ;;
    *)
        printf 'Usage: %s {status|next|menu|set MODE}\n' "$0" >&2
        exit 2
        ;;
esac
