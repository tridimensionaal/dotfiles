#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
TARGET_SCRIPT="${SCRIPT_DIR}/sway/.config/sway/scripts/toggle-output-layout"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "${TEST_ROOT}"' EXIT

BIN_DIR="${TEST_ROOT}/bin"
SWAYMSG_LOG="${TEST_ROOT}/swaymsg.log"
mkdir -p "${BIN_DIR}"

cat >"${BIN_DIR}/swaymsg" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ $* == "-t get_outputs -r" ]]; then
  printf '[]\n'
  exit 0
fi

printf '%s\n' "$*" >>"${SWAYMSG_LOG}"
EOF

cat >"${BIN_DIR}/jq" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "${JQ_OUTPUT}"
EOF

chmod +x "${BIN_DIR}/swaymsg" "${BIN_DIR}/jq"

: >"${SWAYMSG_LOG}"
PATH="${BIN_DIR}:$PATH" \
  SWAYMSG_LOG="${SWAYMSG_LOG}" \
  JQ_OUTPUT=$'DP-1\t0\t20\t1920\nHDMI-A-1\t1920\t0\t2560' \
  "${TARGET_SCRIPT}"

mapfile -t commands <"${SWAYMSG_LOG}"
[[ ${commands[0]} == "output HDMI-A-1 position 0 0" ]]
[[ ${commands[1]} == "output DP-1 position 2560 20" ]]

: >"${SWAYMSG_LOG}"
if PATH="${BIN_DIR}:$PATH" \
  SWAYMSG_LOG="${SWAYMSG_LOG}" \
  JQ_OUTPUT=$'eDP-1\t0\t0\t1920' \
  "${TARGET_SCRIPT}" 2>/dev/null; then
  printf 'expected one-output layout to be rejected\n' >&2
  exit 1
fi

[[ ! -s "${SWAYMSG_LOG}" ]]
