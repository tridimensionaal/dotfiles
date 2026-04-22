#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
TARGET_SCRIPT="${SCRIPT_DIR}/install-arch.sh"

usage() {
  cat <<'EOF'
Usage: ./arch-vm-bootstrap.sh [options]

Deprecated compatibility wrapper. Use ./install-arch.sh instead.
This name is kept temporarily for existing automation and internal VM validation notes.
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  usage
  printf '\n'
  exec "${TARGET_SCRIPT}" --help
fi

exec "${TARGET_SCRIPT}" "$@"
