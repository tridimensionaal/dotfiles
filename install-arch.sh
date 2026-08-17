#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/tridimensionaal/dotfiles.git"
REPO_DIR="${HOME}/dotfiles"
REPO_REF=""
WALLPAPER_URL="https://64.media.tumblr.com/5418cfe910d3aacbd338b62f8e902920/4d297239ab123154-5a/s1280x1920/2c8f9cd34d432881a820204145fd71216e4938a0.jpg"
WALLPAPER_PATH="${HOME}/Pictures/wallpapers/picture_1.jpg"
DRY_RUN=0
DEPS_ONLY=0
SKIP_INSTALL=0
YES=0
PROFILE="full"
SUDO_KEEPALIVE_PID=""

PACMAN_GUI_PACKAGES=(
  stow
  git
  less
  gcr-4
  gnome-keyring
  seahorse
  jq
  curl
  fontconfig
  gtk3
  alacritty
  sway
  swaybg
  waybar
  nwg-bar
  wmenu
  thunar
  grim
  brightnessctl
  nm-connection-editor
  network-manager-applet
  pavucontrol
  gnome-calendar
  gnome-power-manager
  pipewire
  pipewire-pulse
  wireplumber
  xorg-xwayland
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  polkit
  polkit-gnome
  ttf-hack-nerd
  otf-font-awesome
  firefox
)

PACMAN_FULL_PACKAGES=(
  "${PACMAN_GUI_PACKAGES[@]}"
  unzip
  gzip
  tar
  gcc
  bat
  fd
  fzf
  neovim
  ripgrep
  tree-sitter-cli
  tmux
  wl-clipboard
  xdg-utils
  zsh
  starship
  nodejs
  npm
  python-pynvim
)

usage() {
  cat <<'EOF'
Usage: ./install-arch.sh [options]

Prepare an Arch Linux system for this dotfiles repo, then run ./install.sh.

Options:
  --profile full|gui  Select package profile (default: full)
  --repo-url URL      Clone from this Git URL
  --repo-dir DIR      Clone into this directory (default: ~/dotfiles)
  --repo-ref REF      Clone or update to this branch/tag/ref
  --deps-only         Install dependencies but skip cloning and dotfiles install
  --skip-install      Skip running ./install.sh after cloning/updating the repo
  --dry-run           Print the planned actions without changing the system
  --yes               Pass --noconfirm to pacman
  --help              Show this help text

Examples:
  ./install-arch.sh
  ./install-arch.sh --profile gui
  ./install-arch.sh --repo-dir "$HOME/src/dotfiles"
  ./install-arch.sh --deps-only
EOF
}

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  local command_name=$1

  if ! have_command "$command_name"; then
    die "required command not found: ${command_name}"
  fi
}

run() {
  if ((DRY_RUN)); then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

run_in_dir() {
  local directory=$1
  shift

  if ((DRY_RUN)); then
    printf '[dry-run] (cd %q && ' "$directory"
    printf '%q ' "$@"
    printf ')\n'
    return 0
  fi

  (
    cd "$directory"
    "$@"
  )
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --profile)
        (($# >= 2)) || die "--profile requires a value"
        PROFILE=$2
        shift
        ;;
      --profile=*)
        PROFILE=${1#--profile=}
        ;;
      --repo-url)
        (($# >= 2)) || die "--repo-url requires a value"
        REPO_URL=$2
        shift
        ;;
      --repo-dir)
        (($# >= 2)) || die "--repo-dir requires a value"
        REPO_DIR=$2
        shift
        ;;
      --repo-ref)
        (($# >= 2)) || die "--repo-ref requires a value"
        REPO_REF=$2
        shift
        ;;
      --deps-only)
        DEPS_ONLY=1
        ;;
      --skip-install)
        SKIP_INSTALL=1
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --yes)
        YES=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1"
        ;;
    esac
    shift
  done

  case "${PROFILE}" in
    full|gui)
      ;;
    *)
      die "unknown profile: ${PROFILE}"
      ;;
  esac
}

ensure_not_root() {
  if [[ ${EUID} -eq 0 ]]; then
    die "run this script as your normal user, not root"
  fi
}

cleanup() {
  if [[ -n "${SUDO_KEEPALIVE_PID}" ]]; then
    kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
    wait "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
    sudo -k 2>/dev/null || true
  fi
}

start_sudo_keepalive() {
  if ((DRY_RUN)); then
    return
  fi

  log "refreshing sudo credentials"
  sudo -v

  (
    while true; do
      sleep 60
      sudo -n true
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
}

install_pacman_packages() {
  local pacman_args=(-Syu --needed)
  local packages=()

  if ((YES)); then
    pacman_args+=(--noconfirm)
  fi

  case "${PROFILE}" in
    full)
      packages=("${PACMAN_FULL_PACKAGES[@]}")
      ;;
    gui)
      packages=("${PACMAN_GUI_PACKAGES[@]}")
      ;;
  esac

  log "installing Arch packages from official repositories"
  run sudo pacman "${pacman_args[@]}" "${packages[@]}"
}

enable_keyring_and_ssh_agent() {
  log "enabling GNOME Keyring and GCR SSH agent"
  run systemctl --user enable --now gnome-keyring-daemon.socket gnome-keyring-daemon.service
  run systemctl --user enable --now gcr-ssh-agent.socket
}

enable_audio_services() {
  log "enabling PipeWire audio services"
  run systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
}

clone_or_update_repo() {
  if [[ -d "${REPO_DIR}/.git" ]]; then
    log "updating existing repo at ${REPO_DIR}"
    if [[ -n "${REPO_REF}" ]]; then
      run git -C "${REPO_DIR}" fetch origin "${REPO_REF}"
      run git -C "${REPO_DIR}" checkout "${REPO_REF}"
      run git -C "${REPO_DIR}" pull --ff-only origin "${REPO_REF}"
    else
      run git -C "${REPO_DIR}" pull --ff-only
    fi
    return
  fi

  if [[ -e "${REPO_DIR}" ]]; then
    die "target repo directory already exists and is not a Git checkout: ${REPO_DIR}"
  fi

  log "cloning dotfiles repo into ${REPO_DIR}"
  if [[ -n "${REPO_REF}" ]]; then
    run git clone --branch "${REPO_REF}" --single-branch "${REPO_URL}" "${REPO_DIR}"
  else
    run git clone "${REPO_URL}" "${REPO_DIR}"
  fi
}

download_wallpaper() {
  local wallpaper_dir

  if [[ -r "${WALLPAPER_PATH}" ]]; then
    log "wallpaper already present at ${WALLPAPER_PATH}"
    return
  fi

  wallpaper_dir=$(dirname "${WALLPAPER_PATH}")

  log "downloading wallpaper to ${WALLPAPER_PATH}"
  run mkdir -p "${wallpaper_dir}"

  if have_command curl; then
    run curl -fsSL "${WALLPAPER_URL}" -o "${WALLPAPER_PATH}"
    return
  fi

  if have_command wget; then
    run wget -O "${WALLPAPER_PATH}" "${WALLPAPER_URL}"
    return
  fi

  die "unable to download wallpaper: neither curl nor wget is available"
}

refresh_font_cache() {
  if ! have_command fc-cache; then
    return
  fi

  log "refreshing fontconfig cache"
  run fc-cache -f
}

current_login_shell() {
  local target_user

  target_user=${USER:-$(id -un)}

  if have_command getent; then
    getent passwd "${target_user}" | cut -d: -f7
    return
  fi

  printf '%s\n' "${SHELL:-}"
}

is_registered_zsh() {
  local candidate=$1

  [[ "${candidate##*/}" == "zsh" ]] || return 1
  [[ -x "${candidate}" ]] || return 1
  grep -Fxq -- "${candidate}" /etc/shells
}

registered_zsh_path() {
  local candidate

  while IFS= read -r candidate; do
    is_registered_zsh "${candidate}" || continue
    printf '%s\n' "${candidate}"
    return
  done </etc/shells

  return 1
}

ensure_zsh_login_shell() {
  local zsh_path
  local login_shell
  local target_user

  login_shell=$(current_login_shell)
  target_user=${USER:-$(id -un)}

  if is_registered_zsh "${login_shell}"; then
    log "login shell already set to zsh"
    return
  fi

  if ! zsh_path=$(registered_zsh_path); then
    die "no executable Zsh entry found in /etc/shells"
  fi

  log "setting login shell to ${zsh_path} for ${target_user}"
  run sudo chsh -s "${zsh_path}" "${target_user}"
}

install_tmux_plugins() {
  local tpm_dir="${HOME}/.tmux/plugins/tpm"

  if [[ "${PROFILE}" != "full" ]]; then
    log "skipping tmux plugin bootstrap for ${PROFILE} profile"
    return
  fi

  if ((SKIP_INSTALL)); then
    log "skipping tmux plugin bootstrap because ./install.sh was skipped"
    return
  fi

  if [[ -d "${tpm_dir}/.git" ]]; then
    log "updating TPM at ${tpm_dir}"
    run git -C "${tpm_dir}" pull --ff-only
  else
    log "cloning TPM into ${tpm_dir}"
    run git clone https://github.com/tmux-plugins/tpm "${tpm_dir}"
  fi

  log "installing tmux plugins via TPM"
  run "${tpm_dir}/bin/install_plugins"
}

run_repo_install() {
  if ((SKIP_INSTALL)); then
    log "skipping ./install.sh"
    return
  fi

  log "running dotfiles preflight"
  run_in_dir "${REPO_DIR}" ./install.sh --profile "${PROFILE}" --dry-run

  log "installing dotfiles with stow"
  run_in_dir "${REPO_DIR}" ./install.sh --profile "${PROFILE}"
}

main() {
  trap cleanup EXIT

  parse_args "$@"
  ensure_not_root
  require_command sudo
  require_command pacman
  start_sudo_keepalive

  install_pacman_packages
  enable_keyring_and_ssh_agent
  enable_audio_services
  refresh_font_cache

  if ((DEPS_ONLY)); then
    log "dependency-only run complete"
    exit 0
  fi

  clone_or_update_repo
  download_wallpaper
  run_repo_install
  if [[ "${PROFILE}" == "full" ]]; then
    ensure_zsh_login_shell
  else
    log "skipping zsh login shell setup for ${PROFILE} profile"
  fi
  install_tmux_plugins

  log "bootstrap complete"
}

main "$@"
