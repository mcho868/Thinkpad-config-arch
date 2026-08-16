#!/usr/bin/env bash
# Reports fan RPM + CPU temp for the waybar custom/fan module.
set -uo pipefail

FAN_PROC="/proc/acpi/ibm/fan"

find_hwmon() {
  local target="$1"
  for d in /sys/class/hwmon/hwmon*; do
    if [ "$(cat "$d/name" 2>/dev/null)" = "$target" ]; then
      echo "$d"
      return
    fi
  done
}

FAN_DIR="$(find_hwmon thinkpad)"
TEMP_DIR="$(find_hwmon coretemp)"

rpm=$(cat "$FAN_DIR/fan1_input" 2>/dev/null || echo "?")
temp_raw=$(cat "$TEMP_DIR/temp1_input" 2>/dev/null || echo 0)
temp=$((temp_raw / 1000))
level=$(awk -F'[:\t]+' '/^level/{print $2}' "$FAN_PROC" 2>/dev/null)
[ -z "$level" ] && level="?"

if systemctl is-active --quiet thinkfan.service 2>/dev/null; then
    controller="thinkfan automatic"
else
    controller="firmware/manual"
fi

text="${rpm} RPM"
tooltip="CPU: ${temp}°C\nFan: ${rpm} RPM\nLevel: ${level}\nController: ${controller}\nClick to choose control mode"

if [ "${WAYBAR_VERTICAL:-0}" = "1" ]; then
    line_break='\n'
    display="󰈐${line_break}${rpm} RPM"
else
    display="󰈐 ${text}"
fi

printf '{"text": "%s", "tooltip": "%s"}\n' "$display" "$tooltip"
