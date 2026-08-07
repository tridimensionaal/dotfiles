#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
REPO_ROOT=$(dirname "${SCRIPT_DIR}")
export NVIM_CONFIG_ROOT="${REPO_ROOT}/nvim/.config/nvim"

nvim --headless --clean -l "${SCRIPT_DIR}/nvim/wrapping_spec.lua"
nvim --headless --clean -l "${SCRIPT_DIR}/nvim/lsp_config_spec.lua"
nvim --headless --clean -l "${SCRIPT_DIR}/nvim/lsp_client_spec.lua"

XDG_CONFIG_HOME="${REPO_ROOT}/nvim/.config" nvim --headless \
  "+lua local plugins = require('lazy.core.config').plugins; assert(not plugins.LuaSnip); assert(not plugins['mason-lspconfig.nvim'])" \
  "+qa"

printf 'Neovim checks passed.\n'
