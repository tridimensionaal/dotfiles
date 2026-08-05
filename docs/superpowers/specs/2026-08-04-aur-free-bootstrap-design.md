# AUR-Free Bootstrap Design

## Goal

Remove every AUR package and all AUR build automation from the Arch bootstrap while preserving the useful prompt and power-menu behavior.

## Package replacements

`zsh-theme-powerlevel10k` will be replaced by `starship` from Arch's official `extra` repository. Zsh will initialize Starship directly, and the repository will track a compact Dracula-inspired `starship.toml` showing the current directory, Git branch and state, command status and duration, language context, and time. The Powerlevel10k source hook, instant-prompt hook, dependency check, and generated `.p10k.zsh` configuration will be removed.

`wlogout` will be replaced by a repository-owned `power-menu` script. Waybar will invoke the script, which passes exactly three choices to the already-installed official `wmenu` package:

- Shutdown → `systemctl poweroff`
- Suspend → `systemctl suspend`
- Restart → `systemctl reboot`

Cancelling or entering an unrecognized value will exit successfully without running a system action.

## Bootstrap changes

The full profile will install `starship` with `pacman`. Both profiles will continue installing `wmenu`; no new GUI dependency is needed. The installer will remove the AUR package arrays, `--skip-aur`, PKGBUILD key import logic, temporary makepkg configuration, AUR clone/build functions, and the AUR installation phase. `--yes` will apply only to `pacman`.

The remote installer will stop accepting and forwarding `--skip-aur`. `base-devel` will be removed from the GUI package list because the bootstrap will no longer build AUR packages. The full profile retains its explicit compiler and archive dependencies for Neovim tooling.

## Validation

Tests will execute the real power-menu script with controlled `wmenu` and `systemctl` commands, covering all three choices and cancellation. Installer tests will prove that Starship is installed from the official package transaction and that no AUR clone or `makepkg` invocation occurs. Profile tests will require the `starship` command for the Zsh package and will confirm the GUI profile contains no full-only prompt dependency.

Documentation will describe only the official-repository bootstrap. Existing installed AUR packages are not removed automatically; package removal remains an explicit post-migration user action.
