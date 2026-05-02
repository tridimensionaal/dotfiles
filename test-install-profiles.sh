#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
INSTALL_SCRIPT="${SCRIPT_DIR}/install.sh"
ARCH_SCRIPT="${SCRIPT_DIR}/install-arch.sh"
REMOTE_SCRIPT="${SCRIPT_DIR}/remote-install.sh"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "${TEST_ROOT}"' EXIT

BIN_DIR="${TEST_ROOT}/bin"
HOME_DIR="${TEST_ROOT}/home"
LOG_DIR="${TEST_ROOT}/logs"

mkdir -p "${BIN_DIR}" "${HOME_DIR}/Pictures/wallpapers" "${LOG_DIR}"
: >"${HOME_DIR}/Pictures/wallpapers/picture_1.jpg"

fail() {
  printf 'test failure: %s\n' "$*" >&2
  exit 1
}

write_fake_command() {
  local name=$1
  local body=$2

  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -euo pipefail\n'
    printf '%s\n' "$body"
  } >"${BIN_DIR}/${name}"
  chmod +x "${BIN_DIR}/${name}"
}

write_fake_command stow 'printf "%s\n" "$*" >>"'"${LOG_DIR}"'/stow.log"'
write_fake_command fc-list 'printf "%s\n" "Hack Nerd Font" "Font Awesome 7 Free" "Font Awesome 7 Brands"'
write_fake_command nvim 'printf "%s\n" "NVIM v0.12.0"'
write_fake_command tmux 'printf "%s\n" "tmux 3.5"'
write_fake_command zsh 'printf "%s\n" "zsh 5.9"'

for command_name in \
  git curl unzip gzip tar cc tree-sitter wl-copy alacritty sway firefox \
  wmenu-run waybar nm-applet gsettings pactl brightnessctl grim swaynag \
  thunar pkill wireplumber wlogout gnome-calendar pavucontrol \
  gnome-power-statistics gtk-launch sudo pacman gpg fc-cache getent chsh \
  makepkg; do
  [[ -x "${BIN_DIR}/${command_name}" ]] && continue
  write_fake_command "${command_name}" 'exit 0'
done

install_with_profile_gui_stows_desktop_stack() {
  : >"${LOG_DIR}/stow.log"

  PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" "${INSTALL_SCRIPT}" --profile gui --dry-run >/dev/null

  mapfile -t packages < <(awk '{ print $NF }' "${LOG_DIR}/stow.log")
  [[ "${packages[*]}" == "alacritty sway waybar gtk" ]] || {
    printf 'expected gui packages: alacritty sway waybar gtk\n' >&2
    printf 'actual gui packages: %s\n' "${packages[*]}" >&2
    return 1
  }
}

install_default_stows_full_stack() {
  : >"${LOG_DIR}/stow.log"

  PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" "${INSTALL_SCRIPT}" --dry-run >/dev/null

  mapfile -t packages < <(awk '{ print $NF }' "${LOG_DIR}/stow.log")
  [[ "${packages[*]}" == "nvim tmux alacritty zsh sway waybar gtk" ]] || {
    printf 'expected full packages: nvim tmux alacritty zsh sway waybar gtk\n' >&2
    printf 'actual full packages: %s\n' "${packages[*]}" >&2
    return 1
  }
}

install_rejects_profile_with_explicit_packages() {
  if PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" "${INSTALL_SCRIPT}" --profile gui nvim >/dev/null 2>"${LOG_DIR}/install-error.log"; then
    return 1
  fi

  grep -q 'cannot combine --profile with explicit packages' "${LOG_DIR}/install-error.log"
}

install_rejects_unknown_profile() {
  if PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" "${INSTALL_SCRIPT}" --profile laptop >/dev/null 2>"${LOG_DIR}/install-error.log"; then
    return 1
  fi

  grep -q 'unknown profile: laptop' "${LOG_DIR}/install-error.log"
}

arch_gui_profile_uses_gui_dependencies_and_hooks() {
  local output

  output=$(PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" USER=tester "${ARCH_SCRIPT}" --profile gui --dry-run)

  grep -q -- './install.sh --profile gui --dry-run' <<<"${output}"
  grep -q -- './install.sh --profile gui' <<<"${output}"
  grep -q -- 'sway' <<<"${output}"
  grep -q -- 'wlogout' <<<"${output}"
  grep -q -- 'skipping zsh login shell setup for gui profile' <<<"${output}"
  grep -q -- 'skipping tmux plugin bootstrap for gui profile' <<<"${output}"

  if grep -E -- 'pacman|AUR package' <<<"${output}" | grep -Eq -- 'neovim|tmux| zsh |nodejs|npm|python-pynvim|zsh-theme-powerlevel10k'; then
    printf 'gui profile output included full-only dependencies or hooks:\n%s\n' "${output}" >&2
    return 1
  fi
}

remote_forwards_profile_to_arch_installer() {
  write_fake_command git '
if [[ ${1:-} == "clone" ]]; then
  dest=${@: -1}
  mkdir -p "${dest}"
  cat >"${dest}/install-arch.sh" <<SCRIPT
#!/usr/bin/env bash
set -euo pipefail
printf "%s\n" "\$*" >"'"${LOG_DIR}"'/remote-delegate.log"
SCRIPT
  chmod +x "${dest}/install-arch.sh"
  exit 0
fi
exit 0
'
  write_fake_command install-arch.sh 'printf "%s\n" "$*" >"'"${LOG_DIR}"'/remote-delegate.log"'

  PATH="${BIN_DIR}:$PATH" HOME="${HOME_DIR}" USER=tester "${REMOTE_SCRIPT}" --repo-dir "${TEST_ROOT}/remote-dotfiles" --profile gui --dry-run >/dev/null

  grep -q -- '--profile gui' "${LOG_DIR}/remote-delegate.log"
}

install_with_profile_gui_stows_desktop_stack || fail 'install.sh --profile gui package selection'
install_default_stows_full_stack || fail 'install.sh default full package selection'
install_rejects_profile_with_explicit_packages || fail 'install.sh profile plus packages validation'
install_rejects_unknown_profile || fail 'install.sh unknown profile validation'
arch_gui_profile_uses_gui_dependencies_and_hooks || fail 'install-arch.sh gui profile behavior'
remote_forwards_profile_to_arch_installer || fail 'remote-install.sh profile forwarding'
