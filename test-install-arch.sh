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

  if [[ ${2:-} == https://aur.archlinux.org/* ]]; then
    cat >"${dest}/PKGBUILD" <<'PKG'
pkgname=fake
pkgver=1
pkgrel=1
arch=('any')
PKG
  fi

  exit 0
fi

if [[ ${1:-} == "-C" ]]; then
  exit 0
fi

exit 0
EOF

cat >"${BIN_DIR}/gpg" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF

cat >"${BIN_DIR}/fc-cache" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
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

config=
while ((\$# > 0)); do
  if [[ \$1 == "--config" ]]; then
    config=\$2
    shift 2
    continue
  fi
  shift
done

if [[ -z \${config} ]]; then
  echo "missing --config" >&2
  exit 10
fi

grep -q '^PACMAN_AUTH=(sudo)$' "\${config}" || {
  echo "missing PACMAN_AUTH override" >&2
  exit 11
}

grep -q '^source /etc/makepkg.conf$' "\${config}" || {
  echo "missing system config source" >&2
  exit 12
}
EOF

chmod +x "${BIN_DIR}/"*

PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" "${TARGET_SCRIPT}" --deps-only >/dev/null 2>"${LOG_DIR}/stderr.log" || status=$?
status=${status:-0}

if [[ ${status} -ne 0 ]]; then
  cat "${LOG_DIR}/stderr.log" >&2
  exit "${status}"
fi

grep -q -- '--config' "${LOG_DIR}/makepkg.log"
