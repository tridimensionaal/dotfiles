#!/usr/bin/env bash

# Keep successful readings for 20 minutes, but retry startup/network failures
# after one minute. The runtime cache avoids HDD writes on every status update.
umask 077
cache_dir="${XDG_RUNTIME_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/tmux-weather"
mkdir -p "$cache_dir" || exit 1
cache="$cache_dir/current"

exec 9>"$cache_dir/lock"
if ! flock -n 9; then
  tail -n 1 "$cache" 2>/dev/null || printf 'Weather Unavailable\n'
  exit 0
fi

refresh_after=0
weather='Weather Unavailable'
if [[ -r "$cache" ]]; then
  {
    IFS= read -r refresh_after
    IFS= read -r weather
  } <"$cache"
fi
[[ "$refresh_after" =~ ^[0-9]+$ ]] || refresh_after=0

if ((EPOCHSECONDS >= refresh_after)); then
  # wttr.in's automatic location and Celsius match the previous Dracula setup.
  # One bounded HTTPS request replaces its fragile one-second TCP preflight.
  if reading=$(curl --location --fail --silent --connect-timeout 3 --max-time 8 \
    'https://wttr.in/?format=%c%t%20%l&m') &&
    [[ "$reading" == *°C* && "$reading" != *$'\n'* && ${#reading} -lt 256 ]]; then
    weather="${reading/+/}"
    refresh_after=$((EPOCHSECONDS + 1200))
  else
    weather='Weather Unavailable'
    refresh_after=$((EPOCHSECONDS + 60))
  fi
  printf '%s\n%s\n' "$refresh_after" "$weather" >"$cache.tmp"
  mv -f -- "$cache.tmp" "$cache"
fi

printf '%s\n' "$weather"
