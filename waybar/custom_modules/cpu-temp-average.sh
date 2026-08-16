#!/bin/sh

set -eu

CORETEMP_ROOT="/sys/devices/platform/coretemp.0/hwmon"
sum=0
count=0
minimum=0
maximum=0

# coretemp exposes both a package sensor and one sensor per core.  Only use
# sensors whose label starts with "Core" so the package value is not included.
for input in "$CORETEMP_ROOT"/hwmon*/temp*_input; do
    [ -r "$input" ] || continue

    sensor="${input%_input}"
    label_file="${sensor}_label"
    [ -r "$label_file" ] || continue
    label="$(cat "$label_file")"
    case "$label" in
        Core*) ;;
        *) continue ;;
    esac

    raw="$(cat "$input")"
    case "$raw" in
        ''|*[!0-9]*) continue ;;
    esac

    sum=$((sum + raw))
    count=$((count + 1))
    if [ "$minimum" -eq 0 ] || [ "$raw" -lt "$minimum" ]; then minimum=$raw; fi
    if [ "$raw" -gt "$maximum" ]; then maximum=$raw; fi
done

if [ "$count" -eq 0 ]; then
    if [ "${WAYBAR_VERTICAL:-0}" = "1" ]; then
        printf '%s\n' '{"text":"󰔏\\n—°C","class":"unavailable","tooltip":"CPU core average unavailable"}'
    else
        printf '%s\n' '{"text":"—°C","class":"unavailable","tooltip":"CPU core average unavailable"}'
    fi
    exit 0
fi

average="$(awk -v sum="$sum" -v count="$count" 'BEGIN { printf "%.0f", sum / count / 1000 }')"
minimum_c="$(awk -v value="$minimum" 'BEGIN { printf "%.0f", value / 1000 }')"
maximum_c="$(awk -v value="$maximum" 'BEGIN { printf "%.0f", value / 1000 }')"

class="normal"
[ "$average" -ge 90 ] && class="critical"

if [ "${WAYBAR_VERTICAL:-0}" = "1" ]; then
    line_break='\n'
    text="󰔏${line_break}${average}°C"
else
    text="${average}°C"
fi

printf '{"text":"%s","class":"%s","tooltip":"CPU core average: %s°C\\nCore range: %s–%s°C\\nCores measured: %s"}\n' \
    "$text" "$class" "$average" "$minimum_c" "$maximum_c" "$count"
