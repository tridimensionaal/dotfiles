#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/tridimensionaal/dotfiles.git"
REPO_REF="core/v1.0"
REPO_DIR="${HOME}/dotfiles"
DELEGATE_SCRIPT="install-arch.sh"
YES=0
PROFILE="full"
declare -a DELEGATE_ARGS=()

usage() {
  cat <<'EOF'
Usage: ./remote-install.sh [options] [-- bootstrap-args...]

Thin remote bootstrapper for Arch systems. It clones this repo locally and then
delegates to ./install-arch.sh from the checked out repo.

Options:
  --profile full|gui  Select package profile (default: full)
  --repo-url URL      Clone from this Git URL
  --repo-ref REF      Clone this branch/tag/ref (default: core/v1.0)
  --repo-dir DIR      Clone into this directory (default: ~/dotfiles)
  --deps-only         Forward to ./install-arch.sh
  --skip-aur          Forward to ./install-arch.sh
  --skip-install      Forward to ./install-arch.sh
  --dry-run           Forward to ./install-arch.sh
  --yes               Forward to ./install-arch.sh and use --noconfirm for the initial git install
  --help              Show this help text

The bootstrap options above can be passed directly to this wrapper.
Everything after `--` is also forwarded to ./install-arch.sh.
Note: `--deps-only` still clones the repo first because this wrapper delegates
only after a local checkout exists.

Examples:
  ./remote-install.sh --yes
  ./remote-install.sh --profile gui --yes
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
      --profile)
        (($# >= 2)) || die "--profile requires a value"
        PROFILE=$2
        DELEGATE_ARGS+=("$1" "$2")
        shift
        ;;
      --profile=*)
        PROFILE=${1#--profile=}
        DELEGATE_ARGS+=("$1")
        ;;
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
        if [[ "$1" == "--yes" ]]; then
          YES=1
        fi
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

ensure_git() {
  local pacman_args=(-Sy --needed)

  if have_command git; then
    return
  fi

  if ! have_command pacman; then
    die "git is not installed and pacman is unavailable"
  fi

  if ((YES)); then
    pacman_args+=(--noconfirm)
  fi

  log "installing git so the repo can be cloned"
  sudo pacman "${pacman_args[@]}" git
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
