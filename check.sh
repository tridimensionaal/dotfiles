#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
cd "${SCRIPT_DIR}"

bash -n \
  check.sh \
  install.sh \
  install-arch.sh \
  remote-install.sh \
  sway/.config/sway/scripts/toggle-output-layout \
  tests/test-neovim.sh \
  test-toggle-output-layout.sh

python - <<'PY'
import json
import pathlib
import tomllib

json.loads(pathlib.Path("waybar/.config/nwg-bar/bar.json").read_text())
tomllib.loads(pathlib.Path("zsh/.config/starship.toml").read_text())
PY

retired_pattern='aur\.archlinux\.org|makepkg|(^|[^[:alnum:]_])(yay|paru)([^[:alnum:]_]|$)|powerlevel10k|wlogout'
if grep -ERni "${retired_pattern}" \
  install.sh \
  install-arch.sh \
  remote-install.sh \
  zsh/.config \
  waybar/.config \
  sway/.config; then
  printf 'retired AUR or package-build reference found\n' >&2
  exit 1
fi

sway --validate --config sway/.config/sway/config
./test-toggle-output-layout.sh
./tests/test-neovim.sh

printf 'Checks passed.\n'
