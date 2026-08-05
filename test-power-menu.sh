#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
TARGET_SCRIPT="${SCRIPT_DIR}/waybar/.config/waybar/scripts/power-menu"

if [[ ! -x "${TARGET_SCRIPT}" ]]; then
  printf 'power menu is missing or not executable: %s\n' "${TARGET_SCRIPT}" >&2
  exit 1
fi

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "${TEST_ROOT}"' EXIT

BIN_DIR="${TEST_ROOT}/bin"
SYSTEMCTL_LOG="${TEST_ROOT}/systemctl.log"

mkdir -p "${BIN_DIR}"

cat >"${BIN_DIR}/wmenu" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

while IFS= read -r _; do
  :
done

if [[ ${WMENU_CANCEL:-0} == 1 ]]; then
  exit 1
fi

printf '%s\n' "${WMENU_CHOICE:-}"
EOF

cat >"${BIN_DIR}/systemctl" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${SYSTEMCTL_LOG}"
EOF

chmod +x "${BIN_DIR}/wmenu" "${BIN_DIR}/systemctl"

assert_choice() {
  local choice=$1
  local expected=$2
  local actual

  : >"${SYSTEMCTL_LOG}"
  PATH="${BIN_DIR}:$PATH" WMENU_CHOICE="${choice}" "${TARGET_SCRIPT}"
  actual=$(<"${SYSTEMCTL_LOG}")

  if [[ "${actual}" != "${expected}" ]]; then
    printf 'choice %s: expected systemctl %s, got %s\n' "${choice}" "${expected}" "${actual}" >&2
    return 1
  fi
}

assert_no_action() {
  local choice=${1:-}
  local cancel=${2:-0}

  : >"${SYSTEMCTL_LOG}"
  PATH="${BIN_DIR}:$PATH" WMENU_CHOICE="${choice}" WMENU_CANCEL="${cancel}" "${TARGET_SCRIPT}"

  if [[ -s "${SYSTEMCTL_LOG}" ]]; then
    printf 'choice %s unexpectedly invoked systemctl: %s\n' "${choice}" "$(<"${SYSTEMCTL_LOG}")" >&2
    return 1
  fi
}

assert_choice Shutdown poweroff
assert_choice Suspend suspend
assert_choice Restart reboot
assert_no_action Unknown
assert_no_action '' 1
