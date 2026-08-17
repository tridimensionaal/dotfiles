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
  test-toggle-output-layout.sh

python - <<'PY'
import json
import pathlib
import tomllib

json.loads(pathlib.Path("waybar/.config/nwg-bar/bar.json").read_text())
tomllib.loads(pathlib.Path("zsh/.config/starship.toml").read_text())
PY

zsh_test_home=$(mktemp -d)
trap 'rm -rf "$zsh_test_home"' EXIT
mkdir -p "$zsh_test_home/bin" "$zsh_test_home/run"
cat >"$zsh_test_home/.zshrc" <<'EOF'
. "$BASH_SCRIPTS_INIT"
EOF
cat >"$zsh_test_home/local-init" <<'EOF'
BASH_SCRIPTS_LOAD_COUNT=$(( ${BASH_SCRIPTS_LOAD_COUNT:-0} + 1 ))
export BASH_SCRIPTS_LOAD_COUNT
EOF
cat >"$zsh_test_home/bin/starship" <<'EOF'
#!/usr/bin/env sh
exit 0
EOF
chmod +x "$zsh_test_home/bin/starship"

stow -d "$SCRIPT_DIR" -t "$zsh_test_home" zsh
env -u ZDOTDIR \
  HOME="$zsh_test_home" \
  PATH="$zsh_test_home/bin:/usr/bin:/bin" \
  BASH_SCRIPTS_INIT="$zsh_test_home/local-init" \
  XDG_STATE_HOME="$zsh_test_home/.local/state" \
  XDG_CACHE_HOME="$zsh_test_home/.cache" \
  XDG_RUNTIME_DIR="$zsh_test_home/run" \
  zsh -ic '
    [[ $BASH_SCRIPTS_LOAD_COUNT == 1 ]] &&
    [[ :$PATH: == *:$HOME/.local/bin:* ]] &&
    [[ :$PATH: == *:$HOME/bin:* ]]
  '
rm -rf "$zsh_test_home"
trap - EXIT

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

printf 'Checks passed.\n'
