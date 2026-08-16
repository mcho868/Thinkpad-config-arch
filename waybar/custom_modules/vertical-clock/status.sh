#!/usr/bin/env bash

set -u

day="$(LC_ALL=C date '+%a' | tr '[:lower:]' '[:upper:]')"
date_number="$(date '+%d')"
month="$(LC_ALL=C date '+%b' | tr '[:lower:]' '[:upper:]')"
time="$(date '+%I:%M')"
period="$(date '+%p')"

text="${day}"$'\n'"${date_number}"$'\n'"${month}"$'\n'"${time}"$'\n'"${period}"
json_text="${text//$'\n'/\\n}"
tooltip="$(date '+%A, %d %B %Y %H:%M:%S %Z')"

printf '{"text":"%s","tooltip":"%s"}\n' "$json_text" "$tooltip"
