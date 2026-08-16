#!/usr/bin/env bash
# Battery power/charge menu, triggered by clicking the waybar battery module.
set -euo pipefail

BAT_PATH="/sys/class/power_supply/BAT0"
TMPFILES_CONF="/etc/tmpfiles.d/battery-charge-limit.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current=$(cat "$BAT_PATH/charge_control_end_threshold" 2>/dev/null || echo 100)
current_mode=$(powerprofilesctl get 2>/dev/null || printf '%s' balanced)

menu=""
for mode in performance balanced power-saver; do
  case "$mode" in
    performance) label="⚡ performance" ;;
    balanced) label="◐ balanced" ;;
    power-saver) label="☾ power-saver" ;;
  esac

  if [ "$mode" = "$current_mode" ]; then
    menu+="●  ${label}   current\n"
  else
    menu+="○  ${label}\n"
  fi
done

for opt in 100 90 85 80 75; do
  if [ "$opt" = "$current" ]; then
    menu+="●  ${opt}%   current\n"
  else
    menu+="○  ${opt}%\n"
  fi
done

choice=$(printf "%b" "$menu" | wofi --dmenu \
  --conf "$SCRIPT_DIR/wofi-config" \
  --style "$SCRIPT_DIR/wofi-style.css" \
  --prompt "Power profile / Charge limit")

[ -z "$choice" ] && exit 0

# Power profiles are user-level settings; no sudo/pkexec is needed.
case "$choice" in
  *performance*) powerprofilesctl set performance; exit 0 ;;
  *balanced*) powerprofilesctl set balanced; exit 0 ;;
  *power-saver*) powerprofilesctl set power-saver; exit 0 ;;
esac

selected=$(grep -oE '[0-9]+' <<< "$choice" | head -1)
[ -z "$selected" ] && exit 0
[ "$selected" = "$current" ] && exit 0

pkexec bash -c "
echo 0 > '$BAT_PATH/charge_control_start_threshold'
echo $selected > '$BAT_PATH/charge_control_end_threshold'
cat > '$TMPFILES_CONF' <<EOF
w $BAT_PATH/charge_control_end_threshold - - - - $selected
w $BAT_PATH/charge_control_start_threshold - - - - 0
EOF
"
