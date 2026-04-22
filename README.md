# Dotfiles v1.0

Personal dotfiles managed with GNU Stow.

## Layout

Supported Stow packages live at the repo root and map into `$HOME`.

- `nvim` -> `~/.config/nvim/`
- `tmux` -> `~/.config/tmux/tmux.conf` plus `~/.tmux.conf`
- `alacritty` -> `~/.config/alacritty/`
- `zsh` -> `~/.config/zsh/` plus `~/.zshenv`
- `sway` -> `~/.config/sway/`
- `waybar` -> `~/.config/waybar/`
- `gtk` -> `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`

The repo root also keeps the active install and documentation entrypoints:

- `install.sh` -> repo-local Stow installer with dependency preflight
- `arch-vm-bootstrap.sh` -> Arch guest bootstrap helper
- `remote-install.sh` -> thin `curl | bash` entrypoint that clones first, then delegates locally
- `dependencies.md` -> install-time and post-stow dependency inventory
- `docs/` -> active project documentation

The Sway package is split into `~/.config/sway/config` plus ordered fragments under `~/.config/sway/config.d/`.
It also includes window rules for desktop utility apps such as Thunar so they open as centered floating windows instead of tiling.

## Install

Requirements:

- `stow`
- the runtime dependencies described in [dependencies.md](dependencies.md)

Install everything:

```sh
./install.sh
```

On a fresh Arch guest where you also want dependencies installed first:

```sh
./arch-vm-bootstrap.sh --yes
```

For a one-command bootstrap from a clean Arch VM:

```sh
curl -fsSL https://raw.githubusercontent.com/tridimensionaal/dotfiles/core/v1.0/remote-install.sh | bash -s -- --yes
```

The extra `--` belongs to `bash`: it stops bash option parsing and passes the
remaining flags to `remote-install.sh`.

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
- it validates package-scoped runtime dependencies used by the tracked configs before stowing
- it aggregates missing dependency errors across the requested packages
- it preflights every requested package before making changes
- it is safe to re-run
- it does not overwrite conflicting files

The default desktop session integrates utility apps in two places:

- the tray hosts `nm-applet`
- speaker and mic open `pavucontrol`
- battery opens `gnome-power-statistics`
- power opens `wlogout`
- the clock opens `gnome-calendar`

The Sway config adds floating window rules for those utility apps so they open centered like popups instead of splitting the current workspace.

The `gtk` package sets a default dark preference for GTK 3 and GTK 4 applications using `Adwaita`.

## Dependency Tracking

Dependencies now live in [dependencies.md](dependencies.md) instead of the old distro-specific install scripts. The manifest is derived from the tracked configs and separates:

- install-time dependencies enforced by `install.sh`
- post-stow bootstrap state handled later by plugin/tool managers
- hardware and environment assumptions

For a reproducible Arch GUI validation path, use [docs/arch-vm-test.md](docs/arch-vm-test.md). That guide covers the current `virt-manager` + `archinstall` + Sway test flow and the expected runtime checks after `./install.sh`.

## Non-XDG Exceptions

Two home-level files remain on purpose:

- `~/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"` so the rest of the Zsh config can live under XDG paths.
- `~/.tmux.conf` sources `~/.config/tmux/tmux.conf` because tmux still looks for the traditional top-level config by default.

Everything else is kept under `~/.config` where the application supports it cleanly.
