#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
REPO_ROOT=$(dirname "${SCRIPT_DIR}")
export NVIM_CONFIG_ROOT="${REPO_ROOT}/nvim/.config/nvim"

nvim --headless --clean -l "${SCRIPT_DIR}/nvim/wrapping_spec.lua"

printf 'Neovim checks passed.\n'
