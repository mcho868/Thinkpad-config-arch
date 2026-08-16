#!/usr/bin/env bash

set -u

temperature="$(hyprctl hyprsunset temperature 2>/dev/null | tr -d '[:space:]')"
line_break='\n'

if [[ "$temperature" =~ ^[0-9]+$ ]]; then
    if (( temperature < 5500 )); then
        if [[ "${WAYBAR_VERTICAL:-0}" == "1" ]]; then
            text="󰖔${line_break}${temperature}K"
        else
            text="󰖔 ${temperature}K"
        fi
        class="warm"
        tooltip="Hyprsunset active — ${temperature}K"
    else
        if [[ "${WAYBAR_VERTICAL:-0}" == "1" ]]; then
            text="󰖔${line_break}${temperature}K"
        else
            text="󰖔 ${temperature}K"
        fi
        class="day"
        tooltip="Hyprsunset daytime profile — ${temperature}K"
    fi
else
    if [[ "${WAYBAR_VERTICAL:-0}" == "1" ]]; then
        text="󰖔${line_break}—"
    else
        text="󰖔 —"
    fi
    class="unavailable"
    tooltip="Hyprsunset is not running"
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
