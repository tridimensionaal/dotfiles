#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)

PACKAGES=(nvim tmux alacritty zsh sway waybar gtk)
DRY_RUN=0
declare -a MISSING_DEPENDENCIES=()
declare -a WARNINGS=()

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run|-n] [package ...]

Install GNU Stow packages into $HOME.

Examples:
  ./install.sh
  ./install.sh --dry-run
  ./install.sh nvim zsh
EOF
}

is_known_package() {
  local candidate=$1
  local package
  for package in "${PACKAGES[@]}"; do
    if [[ "$package" == "$candidate" ]]; then
      return 0
    fi
  done

  return 1
}

require_command() {
  local command_name=$1
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

version_ge() {
  local left=$1
  local right=$2

  if [[ "$left" == "$right" ]]; then
    return 0
  fi

  [[ "$(printf '%s\n%s\n' "$right" "$left" | sort -V | tail -n1)" == "$left" ]]
}

version_from_output() {
  local text=$1

  grep -Eo '[0-9]+([.][0-9]+)+' <<<"$text" | head -n1
}

tmux_version() {
  local output
  output=$(tmux -V 2>/dev/null || true)
  version_from_output "$output"
}

zsh_version() {
  local output
  output=$(zsh --version 2>/dev/null || true)
  version_from_output "$output"
}

nvim_version() {
  local output
  output=$(nvim --version 2>/dev/null | head -n1 || true)
  version_from_output "$output"
}

have_font_family() {
  local family=$1

  if ! have_command fc-list; then
    return 1
  fi

  fc-list : family | grep -Fqi "$family"
}

add_missing() {
  local package=$1
  local kind=$2
  local value=$3

  MISSING_DEPENDENCIES+=("$package|$kind|$value")
}

add_warning() {
  local package=$1
  local value=$2

  WARNINGS+=("$package|$value")
}

check_command_dependency() {
  local package=$1
  local command_name=$2

  if ! have_command "$command_name"; then
    add_missing "$package" command "$command_name"
  fi
}

check_file_dependency() {
  local package=$1
  local path=$2

  if [[ ! -r "$path" ]]; then
    add_missing "$package" file "$path"
  fi
}

check_font_dependency() {
  local package=$1
  local family=$2

  if ! have_command fc-list; then
    add_missing "$package" command fc-list
    return
  fi

  if ! have_font_family "$family"; then
    add_missing "$package" font "$family"
  fi
}

check_version_dependency() {
  local package=$1
  local command_name=$2
  local minimum_version=$3
  local current_version=$4

  if [[ -z "$current_version" ]]; then
    add_missing "$package" version "$command_name >= $minimum_version (unable to detect installed version)"
    return
  fi

  if ! version_ge "$current_version" "$minimum_version"; then
    add_missing "$package" version "$command_name >= $minimum_version (found $current_version)"
  fi
}

check_any_command_dependency() {
  local package=$1
  shift

  local candidate
  for candidate in "$@"; do
    if have_command "$candidate"; then
      return
    fi
  done

  add_missing "$package" command_group "$(IFS='|'; printf '%s' "$*")"
}

check_nvim_dependencies() {
  local package=$1

  check_command_dependency "$package" git
  check_command_dependency "$package" nvim
  if have_command nvim; then
    check_version_dependency "$package" nvim "0.12.0" "$(nvim_version)"
  fi
  check_any_command_dependency "$package" curl wget
  check_command_dependency "$package" unzip
  check_command_dependency "$package" gzip
  check_any_command_dependency "$package" tar gtar
  check_any_command_dependency "$package" cc gcc clang
  check_command_dependency "$package" tree-sitter
}

check_tmux_dependencies() {
  local package=$1

  check_command_dependency "$package" tmux
  if have_command tmux; then
    check_version_dependency "$package" tmux "1.9" "$(tmux_version)"
  fi
  check_command_dependency "$package" git
  check_command_dependency "$package" bash
  check_any_command_dependency "$package" wl-copy xsel xclip

  if [[ ! -x "$HOME/.tmux/plugins/tpm/tpm" ]]; then
    add_warning "$package" "TPM is not installed at ~/.tmux/plugins/tpm; plugin-managed tmux features will not work until it is installed"
  fi
}

check_alacritty_dependencies() {
  local package=$1

  check_command_dependency "$package" alacritty
  check_font_dependency "$package" "Hack Nerd Font"
}

check_zsh_dependencies() {
  local package=$1

  check_command_dependency "$package" zsh
  if have_command zsh; then
    check_version_dependency "$package" zsh "5.1" "$(zsh_version)"
  fi
  check_file_dependency "$package" /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
}

check_sway_dependencies() {
  local package=$1

  check_command_dependency "$package" sway
  check_command_dependency "$package" alacritty
  check_command_dependency "$package" firefox
  check_command_dependency "$package" wmenu-run
  check_command_dependency "$package" waybar
  check_command_dependency "$package" nm-applet
  check_command_dependency "$package" gsettings
  check_command_dependency "$package" pactl
  check_command_dependency "$package" brightnessctl
  check_command_dependency "$package" grim
  check_command_dependency "$package" swaynag
  check_command_dependency "$package" thunar
  check_command_dependency "$package" pkill
  check_file_dependency "$package" "$HOME/Pictures/wallpapers/picture_1.jpg"
  check_file_dependency "$package" /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
}

check_waybar_dependencies() {
  local package=$1

  check_command_dependency "$package" waybar
  check_command_dependency "$package" wireplumber
  check_command_dependency "$package" wlogout
  check_command_dependency "$package" gnome-calendar
  check_command_dependency "$package" pavucontrol
  check_command_dependency "$package" gnome-power-statistics
  check_font_dependency "$package" "Hack Nerd Font"
  check_font_dependency "$package" "Font Awesome 7 Free"
  check_font_dependency "$package" "Font Awesome 7 Brands"
}

check_gtk_dependencies() {
  local package=$1

  check_command_dependency "$package" gtk-launch
  check_font_dependency "$package" "Hack Nerd Font"
}

check_package_dependencies() {
  local package=$1

  case "$package" in
    nvim)
      check_nvim_dependencies "$package"
      ;;
    tmux)
      check_tmux_dependencies "$package"
      ;;
    alacritty)
      check_alacritty_dependencies "$package"
      ;;
    zsh)
      check_zsh_dependencies "$package"
      ;;
    sway)
      check_sway_dependencies "$package"
      ;;
    waybar)
      check_waybar_dependencies "$package"
      ;;
    gtk)
      check_gtk_dependencies "$package"
      ;;
  esac
}

report_missing_dependencies() {
  local item
  local package
  local kind
  local value

  if ((${#MISSING_DEPENDENCIES[@]} == 0)); then
    return
  fi

  printf 'Error: missing dependencies:\n' >&2
  for item in "${MISSING_DEPENDENCIES[@]}"; do
    IFS='|' read -r package kind value <<<"$item"
    case "$kind" in
      command)
        printf '  - [%s] command not found: %s\n' "$package" "$value" >&2
        ;;
      command_group)
        printf '  - [%s] none of these commands were found: %s\n' "$package" "$value" >&2
        ;;
      file)
        printf '  - [%s] required file not found: %s\n' "$package" "$value" >&2
        ;;
      font)
        printf '  - [%s] required font family not found: %s\n' "$package" "$value" >&2
        ;;
      version)
        printf '  - [%s] version requirement not met: %s\n' "$package" "$value" >&2
        ;;
    esac
  done

  exit 1
}

report_warnings() {
  local item
  local package
  local value

  if ((${#WARNINGS[@]} == 0)); then
    return
  fi

  printf 'Warnings:\n' >&2
  for item in "${WARNINGS[@]}"; do
    IFS='|' read -r package value <<<"$item"
    printf '  - [%s] %s\n' "$package" "$value" >&2
  done
}

run_stow() {
  local package=$1
  shift

  if ! stow "$@" -d "$SCRIPT_DIR" -t "$HOME" "$package"; then
    printf 'Error: failed while processing package %s\n' "$package" >&2
    exit 1
  fi
}

main() {
  local requested=()
  local package

  while (($# > 0)); do
    case "$1" in
      --dry-run|-n)
        DRY_RUN=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        if ! is_known_package "$1"; then
          printf 'Error: unknown package: %s\n' "$1" >&2
          usage >&2
          exit 1
        fi
        requested+=("$1")
        ;;
    esac
    shift
  done

  require_command stow

  if ((${#requested[@]} == 0)); then
    requested=("${PACKAGES[@]}")
  fi

  MISSING_DEPENDENCIES=()
  WARNINGS=()
  for package in "${requested[@]}"; do
    check_package_dependencies "$package"
  done
  report_missing_dependencies
  report_warnings

  for package in "${requested[@]}"; do
    printf 'Preflight: %s\n' "$package"
    run_stow "$package" -n -v -R
  done

  if ((DRY_RUN)); then
    printf 'Dry run complete. No changes were made.\n'
    exit 0
  fi

  for package in "${requested[@]}"; do
    printf 'Installing: %s\n' "$package"
    run_stow "$package" -v -R
  done

  printf 'Done.\n'
}

main "$@"
