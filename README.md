# Dotfiles v1.0

Personal dotfiles managed with GNU Stow.

## Layout

Each top-level directory is a Stow package that maps into `$HOME`.

- `nvim` -> `~/.config/nvim/`
- `tmux` -> `~/.config/tmux/tmux.conf` plus `~/.tmux.conf`
- `alacritty` -> `~/.config/alacritty/`
- `zsh` -> `~/.config/zsh/` plus `~/.zshenv`
- `sway` -> `~/.config/sway/`
- `waybar` -> `~/.config/waybar/`
- `legacy` -> old configs kept for reference
- `arch` and `ubuntu` -> deprecated historical notes, not the main install flow

## Install

Requirements:

- `stow`
- the runtime dependencies described in [dependencies.md](dependencies.md)

Install everything:

```sh
./install.sh
```

Dry-run first:

```sh
./install.sh --dry-run
```

Install only one or a few packages:

```sh
./install.sh nvim zsh
```

Uninstall one package:

```sh
stow -D -t "$HOME" nvim
```

The install script is conservative:

- it requires `stow`
- it validates package-scoped host/runtime dependencies before stowing
- it aggregates missing dependency errors across the requested packages
- it preflights every requested package before making changes
- it is safe to re-run
- it does not overwrite conflicting files

## Dependency Tracking

Dependencies now live in [dependencies.md](dependencies.md) instead of the old distro-specific install scripts. The manifest is derived from the tracked configs and separates:

- install-time dependencies enforced by `install.sh`
- post-stow bootstrap state handled later by plugin/tool managers
- hardware and environment assumptions

## Non-XDG Exceptions

Two home-level files remain on purpose:

- `~/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"` so the rest of the Zsh config can live under XDG paths.
- `~/.tmux.conf` sources `~/.config/tmux/tmux.conf` because tmux still looks for the traditional top-level config by default.

Everything else is kept under `~/.config` where the application supports it cleanly.

## Deprecated Paths

`ubuntu/install.sh` and `arch/install.sh` are no longer part of the primary workflow. They remain only as historical references and point back to the Stow-based install flow.
