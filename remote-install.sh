#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/tridimensionaal/dotfiles.git"
REPO_REF="core/v1.0"
REPO_DIR="${HOME}/dotfiles"
DELEGATE_SCRIPT="arch-vm-bootstrap.sh"
declare -a DELEGATE_ARGS=()

usage() {
  cat <<'EOF'
Usage: ./remote-install.sh [options] [-- bootstrap-args...]

Thin remote bootstrapper for Arch guests. It clones this repo locally and then
delegates to ./arch-vm-bootstrap.sh from the checked out repo.

Options:
  --repo-url URL      Clone from this Git URL
  --repo-ref REF      Clone this branch/tag/ref (default: core/v1.0)
  --repo-dir DIR      Clone into this directory (default: ~/dotfiles)
  --deps-only         Forward to ./arch-vm-bootstrap.sh
  --skip-aur          Forward to ./arch-vm-bootstrap.sh
  --skip-install      Forward to ./arch-vm-bootstrap.sh
  --dry-run           Forward to ./arch-vm-bootstrap.sh
  --yes               Forward to ./arch-vm-bootstrap.sh
  --help              Show this help text

The bootstrap options above can be passed directly to this wrapper.
Everything after `--` is also forwarded to ./arch-vm-bootstrap.sh.
Note: `--deps-only` still clones the repo first because this wrapper delegates
only after a local checkout exists.

Examples:
  ./remote-install.sh --yes
  ./remote-install.sh --repo-ref main --yes --skip-install
  ./remote-install.sh --repo-ref main -- --some-future-flag
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

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --repo-url)
        (($# >= 2)) || die "--repo-url requires a value"
        REPO_URL=$2
        shift
        ;;
      --repo-ref)
        (($# >= 2)) || die "--repo-ref requires a value"
        REPO_REF=$2
        shift
        ;;
      --repo-dir)
        (($# >= 2)) || die "--repo-dir requires a value"
        REPO_DIR=$2
        shift
        ;;
      --deps-only|--skip-aur|--skip-install|--dry-run|--yes)
        DELEGATE_ARGS+=("$1")
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      --)
        shift
        DELEGATE_ARGS=("$@")
        break
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

ensure_git() {
  if have_command git; then
    return
  fi

  if ! have_command pacman; then
    die "git is not installed and pacman is unavailable"
  fi

  log "installing git so the repo can be cloned"
  sudo pacman -Sy --needed git
}

clone_or_update_repo() {
  if [[ -d "${REPO_DIR}/.git" ]]; then
    log "updating existing repo at ${REPO_DIR}"
    git -C "${REPO_DIR}" fetch origin "${REPO_REF}"
    git -C "${REPO_DIR}" checkout "${REPO_REF}"
    git -C "${REPO_DIR}" pull --ff-only origin "${REPO_REF}"
    return
  fi

  if [[ -e "${REPO_DIR}" ]]; then
    die "target repo directory already exists and is not a Git checkout: ${REPO_DIR}"
  fi

  log "cloning ${REPO_URL} into ${REPO_DIR}"
  git clone --branch "${REPO_REF}" --single-branch "${REPO_URL}" "${REPO_DIR}"
}

delegate() {
  local script_path="${REPO_DIR}/${DELEGATE_SCRIPT}"

  [[ -x "${script_path}" ]] || die "delegate script is missing or not executable: ${script_path}"

  log "delegating to ${DELEGATE_SCRIPT}"
  exec "${script_path}" --repo-dir "${REPO_DIR}" --repo-ref "${REPO_REF}" "${DELEGATE_ARGS[@]}"
}

main() {
  parse_args "$@"
  ensure_not_root
  ensure_git
  clone_or_update_repo
  delegate
}

main "$@"
