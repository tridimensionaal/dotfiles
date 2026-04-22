#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/tridimensionaal/dotfiles.git"
REPO_DIR="${HOME}/dotfiles"
REPO_REF=""
WALLPAPER_URL="https://64.media.tumblr.com/5418cfe910d3aacbd338b62f8e902920/4d297239ab123154-5a/s1280x1920/2c8f9cd34d432881a820204145fd71216e4938a0.jpg"
WALLPAPER_PATH="${HOME}/Pictures/wallpapers/picture_1.jpg"
DRY_RUN=0
DEPS_ONLY=0
SKIP_AUR=0
SKIP_INSTALL=0
YES=0
SUDO_KEEPALIVE_PID=""
GPG_KEYSERVER="hkps://keyserver.ubuntu.com"

PACMAN_PACKAGES=(
  stow
  git
  base-devel
  curl
  unzip
  gzip
  tar
  gcc
  fontconfig
  gtk3
  neovim
  tree-sitter-cli
  tmux
  wl-clipboard
  alacritty
  zsh
  sway
  swaybg
  waybar
  wmenu
  thunar
  grim
  brightnessctl
  nm-connection-editor
  network-manager-applet
  pavucontrol
  gnome-calendar
  gnome-power-manager
  wireplumber
  libpulse
  xorg-xwayland
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  polkit
  polkit-gnome
  ttf-hack-nerd
  otf-font-awesome
  firefox
  nodejs
  npm
  python-pynvim
)

AUR_PACKAGES=(
  zsh-theme-powerlevel10k
  wlogout
)

usage() {
  cat <<'EOF'
Usage: ./arch-vm-bootstrap.sh [options]

Prepare an Arch Sway VM for this dotfiles repo, then run ./install.sh.

Options:
  --repo-url URL      Clone from this Git URL
  --repo-dir DIR      Clone into this directory (default: ~/dotfiles)
  --repo-ref REF      Clone or update to this branch/tag/ref
  --deps-only         Install dependencies but skip cloning and dotfiles install
  --skip-aur          Skip AUR package installs
  --skip-install      Skip running ./install.sh after cloning/updating the repo
  --dry-run           Print the planned actions without changing the system
  --yes               Pass --noconfirm to pacman and makepkg
  --help              Show this help text

Examples:
  ./arch-vm-bootstrap.sh
  ./arch-vm-bootstrap.sh --repo-dir "$HOME/src/dotfiles"
  ./arch-vm-bootstrap.sh --deps-only
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

list_validpgpkeys() {
  local pkgbuild_path=$1

  awk '
    /^validpgpkeys=\(/ { in_keys=1 }
    in_keys { print }
    in_keys && /\)/ { exit }
  ' "$pkgbuild_path" | grep -Eo '[A-F0-9]{40}' || true
}

have_gpg_public_key() {
  local fingerprint=$1
  gpg --list-keys --with-colons "$fingerprint" >/dev/null 2>&1
}

ensure_aur_signing_keys() {
  local package_dir=$1
  local fingerprint
  local found_keys=0

  while IFS= read -r fingerprint; do
    [[ -n "$fingerprint" ]] || continue
    found_keys=1

    if have_gpg_public_key "$fingerprint"; then
      continue
    fi

    log "importing missing AUR signing key: ${fingerprint}"
    run gpg --keyserver "${GPG_KEYSERVER}" --recv-keys "${fingerprint}"
  done < <(list_validpgpkeys "${package_dir}/PKGBUILD")

  if ((found_keys)) && ((DRY_RUN)); then
    return
  fi
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
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
      --skip-aur)
        SKIP_AUR=1
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

  if ((YES)); then
    pacman_args+=(--noconfirm)
  fi

  log "installing Arch packages from official repositories"
  run sudo pacman "${pacman_args[@]}" "${PACMAN_PACKAGES[@]}"
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

install_aur_package() {
  local package=$1
  local makepkg_args=(-si --needed)
  local build_root
  local package_dir

  if pacman -Q "$package" >/dev/null 2>&1; then
    log "AUR package already installed: ${package}"
    return
  fi

  if ((YES)); then
    makepkg_args+=(--noconfirm)
  fi

  build_root=$(mktemp -d)
  package_dir="${build_root}/${package}"

  log "building AUR package: ${package}"
  run git clone "https://aur.archlinux.org/${package}.git" "${package_dir}"
  ensure_aur_signing_keys "${package_dir}"
  run_in_dir "${package_dir}" makepkg "${makepkg_args[@]}"

  if ((DRY_RUN)); then
    rmdir "${build_root}" 2>/dev/null || true
  else
    rm -rf "${build_root}"
  fi
}

install_aur_packages() {
  local package

  if ((SKIP_AUR)); then
    log "skipping AUR packages"
    return
  fi

  for package in "${AUR_PACKAGES[@]}"; do
    install_aur_package "$package"
  done
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

run_repo_install() {
  if ((SKIP_INSTALL)); then
    log "skipping ./install.sh"
    return
  fi

  log "running dotfiles preflight"
  run_in_dir "${REPO_DIR}" ./install.sh --dry-run

  log "installing dotfiles with stow"
  run_in_dir "${REPO_DIR}" ./install.sh
}

main() {
  trap cleanup EXIT

  parse_args "$@"
  ensure_not_root
  require_command sudo
  require_command pacman
  start_sudo_keepalive

  install_pacman_packages
  install_aur_packages

  if ((DEPS_ONLY)); then
    log "dependency-only run complete"
    exit 0
  fi

  clone_or_update_repo
  download_wallpaper
  run_repo_install

  log "bootstrap complete"
}

main "$@"
