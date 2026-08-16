#!/bin/sh

set -eu

BATTERY_PATH="/sys/class/power_supply/BAT0"

read_value() {
    file="$BATTERY_PATH/$1"
    if [ -r "$file" ]; then
        cat "$file"
    else
        printf '%s' ""
    fi
}

capacity="$(read_value capacity)"
status="$(read_value status)"
cycles="$(read_value cycle_count)"
energy_full="$(read_value energy_full)"
energy_design="$(read_value energy_full_design)"
energy_now="$(read_value energy_now)"
power_now="$(read_value power_now)"

[ -n "$capacity" ] || exit 0
[ -n "$cycles" ] || cycles="Unavailable"

case "$energy_design" in
    ''|0) health="Unavailable" ;;
    *) health="$(awk -v full="$energy_full" -v design="$energy_design" 'BEGIN { printf "%.0f", (full / design) * 100 }')" ;;
esac

power_mode="$(powerprofilesctl get 2>/dev/null || printf '%s' 'Unavailable')"

# Estimate the remaining time from the battery's energy and current power draw.
# Values exposed by sysfs are normally in µWh and µW, so their ratio is hours.
format_duration() {
    awk -v hours="$1" 'BEGIN {
        if (hours <= 0) {
            printf "%s", "Unavailable"
            exit
        }
        total_minutes = int(hours * 60 + 0.5)
        h = int(total_minutes / 60)
        m = total_minutes % 60
        if (h > 0) {
            printf "%dh %02dm", h, m
        } else {
            printf "%dm", m
        }
    }'
}

time_label="Time: Unavailable"
if [ -n "$energy_now" ] && [ -n "$power_now" ]; then
    case "$status" in
        Discharging)
            time_left="$(awk -v now="$energy_now" -v power="$power_now" 'BEGIN {
                if (power > 0) printf "%.6f", now / power
            }')"
            [ -n "$time_left" ] && time_label="Time remaining: $(format_duration "$time_left")"
            ;;
        Charging)
            time_left="$(awk -v now="$energy_now" -v full="$energy_full" -v power="$power_now" 'BEGIN {
                if (power > 0 && full > now) printf "%.6f", (full - now) / power
            }')"
            [ -n "$time_left" ] && time_label="Until full: $(format_duration "$time_left")"
            ;;
        Full)
            time_label="Time: Fully charged"
            ;;
    esac
fi

icon_index=$((capacity / 10))
[ "$icon_index" -gt 10 ] && icon_index=10

default_icons='󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹'
charging_icons='󰢟 󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅'
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    icon="$(printf '%s\n' "$charging_icons" | cut -d' ' -f$((icon_index + 1)))"
    class="charging"
else
    icon="$(printf '%s\n' "$default_icons" | cut -d' ' -f$((icon_index + 1)))"
    class="discharging"
fi

tooltip="Status: $status\\n$time_label\\nPower mode: $power_mode\\nBattery cycles: $cycles\\nMaximum health: ${health}%"
if [ "${WAYBAR_VERTICAL:-0}" = "1" ]; then
    line_break='\n'
    text="${icon}${line_break}${capacity}%"
else
    text="${capacity}% ${icon}"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$text" "$tooltip" "$class"
