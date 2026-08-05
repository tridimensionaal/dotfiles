#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)

BAR_CONFIG="${SCRIPT_DIR}/waybar/.config/nwg-bar/bar.json"
BAR_STYLE="${SCRIPT_DIR}/waybar/.config/nwg-bar/style.css"
WAYBAR_CONFIG="${SCRIPT_DIR}/waybar/.config/waybar/config"

python - "${BAR_CONFIG}" <<'PY'
import json
import pathlib
import sys

config_path = pathlib.Path(sys.argv[1])
expected = [
    {
        "label": "Suspend",
        "exec": "systemctl suspend",
        "icon": "/usr/share/nwg-bar/images/system-suspend.svg",
    },
    {
        "label": "Restart",
        "exec": "systemctl reboot",
        "icon": "/usr/share/nwg-bar/images/system-reboot.svg",
    },
    {
        "label": "Shutdown",
        "exec": "systemctl poweroff",
        "icon": "/usr/share/nwg-bar/images/system-shutdown.svg",
    },
]

if not config_path.is_file():
    raise SystemExit(f"nwg-bar config is missing: {config_path}")

actual = json.loads(config_path.read_text())
if actual != expected:
    raise SystemExit(
        "nwg-bar actions do not match the minimal power-menu contract\n"
        f"expected: {expected!r}\n"
        f"actual:   {actual!r}"
    )
PY

if ! grep -Fq '"on-click": "nwg-bar -i 64"' "${WAYBAR_CONFIG}"; then
  printf 'Waybar must launch the compact nwg-bar menu with 64-pixel icons\n' >&2
  exit 1
fi

if grep -Eq '"on-click"[[:space:]]*:[[:space:]]*"[^"]*nwg-bar[^"]*(^|[[:space:]])-f([[:space:]]|$)' "${WAYBAR_CONFIG}"; then
  printf 'Waybar must not launch nwg-bar in full-screen mode\n' >&2
  exit 1
fi

if [[ ! -f "${BAR_STYLE}" ]]; then
  printf 'nwg-bar stylesheet is missing: %s\n' "${BAR_STYLE}" >&2
  exit 1
fi

required_selectors=(
  'window'
  '#outer-box'
  '#inner-box'
  'button'
  'button:hover'
  'button:focus'
  'image'
  'label'
)

for selector in "${required_selectors[@]}"; do
  if ! grep -Eq "^[[:space:]]*${selector//\#/\\#}[[:space:]]*\\{" "${BAR_STYLE}"; then
    printf 'nwg-bar stylesheet is missing selector: %s\n' "${selector}" >&2
    exit 1
  fi
done
