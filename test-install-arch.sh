#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
TARGET_SCRIPT="${SCRIPT_DIR}/install-arch.sh"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "${TEST_ROOT}"' EXIT

BIN_DIR="${TEST_ROOT}/bin"
HOME_DIR="${TEST_ROOT}/home"
LOG_DIR="${TEST_ROOT}/logs"

mkdir -p "${BIN_DIR}" "${HOME_DIR}" "${LOG_DIR}"

cat >"${BIN_DIR}/sudo" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${LOG_DIR}/sudo.log"

if [[ \${1:-} == "-v" || \${1:-} == "-n" || \${1:-} == "-k" ]]; then
  exit 0
fi

exec "\$@"
EOF

cat >"${BIN_DIR}/pacman" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${LOG_DIR}/pacman.log"

if [[ \${1:-} == "-Q" ]]; then
  exit 1
fi

exit 0
EOF

cat >"${BIN_DIR}/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "clone" ]]; then
  dest=${@: -1}
  mkdir -p "${dest}"

  if [[ ${2:-} == https://github.com/tmux-plugins/tpm ]]; then
    mkdir -p "${dest}/bin"
    cat >"${dest}/bin/install_plugins" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
exit 0
SCRIPT
    chmod +x "${dest}/bin/install_plugins"
  else
    cat >"${dest}/install.sh" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
exit 0
SCRIPT
    chmod +x "${dest}/install.sh"
  fi

  exit 0
fi

if [[ ${1:-} == "-C" ]]; then
  exit 0
fi

exit 0
EOF

cat >"${BIN_DIR}/fc-cache" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF

cat >"${BIN_DIR}/getent" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == "passwd" ]]; then
  printf 'tester:x:1000:1000:Tester:/home/tester:/usr/sbin/zsh\n'
  exit 0
fi

exit 1
EOF

cat >"${BIN_DIR}/chsh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${LOG_DIR}/chsh.log"
exit 0
EOF

cat >"${BIN_DIR}/systemctl" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${LOG_DIR}/systemctl.log"
exit 0
EOF

cat >"${BIN_DIR}/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
out=
while (($# > 0)); do
  if [[ $1 == "-o" ]]; then
    out=$2
    shift 2
    continue
  fi
  shift
done

if [[ -n ${out} ]]; then
  : >"${out}"
fi
EOF

cat >"${BIN_DIR}/makepkg" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "\$*" >>"${LOG_DIR}/makepkg.log"
printf 'makepkg must not be invoked\n' >&2
exit 97
EOF

chmod +x "${BIN_DIR}/"*

PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" USER=tester "${TARGET_SCRIPT}" >/dev/null 2>"${LOG_DIR}/stderr.log" || status=$?
status=${status:-0}

if [[ ${status} -ne 0 ]]; then
  cat "${LOG_DIR}/stderr.log" >&2
  exit "${status}"
fi

if [[ -e "${LOG_DIR}/makepkg.log" ]]; then
  printf 'makepkg was invoked during an official-repository bootstrap\n' >&2
  exit 1
fi
grep -Fxq -- '-s /bin/zsh tester' "${LOG_DIR}/chsh.log"
grep -Eq -- '(^| )less( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )gcr-4( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )gnome-keyring( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )seahorse( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )jq( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )starship( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )pipewire( |$)' "${LOG_DIR}/pacman.log"
grep -Eq -- '(^| )pipewire-pulse( |$)' "${LOG_DIR}/pacman.log"
if grep -Eq -- '(^| )libpulse( |$)' "${LOG_DIR}/pacman.log"; then
  printf 'libpulse should not be a direct bootstrap package\n' >&2
  exit 1
fi
if grep -Eq -- '(^| )base-devel( |$)' "${LOG_DIR}/pacman.log"; then
  printf 'base-devel should not be required by the bootstrap\n' >&2
  exit 1
fi
grep -Fxq -- '--user enable --now gcr-ssh-agent.socket' "${LOG_DIR}/systemctl.log"
grep -Fxq -- '--user enable --now gnome-keyring-daemon.socket gnome-keyring-daemon.service' "${LOG_DIR}/systemctl.log"
grep -Fxq -- '--user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service' "${LOG_DIR}/systemctl.log"
