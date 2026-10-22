# Zsh

The main Zsh config lives under `~/.config/zsh` with one tracked top-level entry:

- `~/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"`

The main config also sources `~/.zshrc` when it is readable. This optional file is machine-owned and untracked; installers can add local integrations there without dirtying this repository.

Install it with:

```sh
./install.sh zsh
```

Tracked config files:

- `~/.config/zsh/.zshrc`
- `~/.config/zsh/.zsh_aliases`
- `~/.config/starship.toml`
- `~/.config/git/config`

## Notes

- history is stored at `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history`
- Starship is initialized at the end of the main Zsh config and reads `~/.config/starship.toml`
- Starship allows 500 ms for directory scans and 2 seconds for external commands, including Git, to accommodate cold disk reads
- the global Git config refreshes commit-graph caches after fetches that download packs and during automatic maintenance once 32 reachable commits are missing from the cache; this speeds up ahead/behind counts across repositories
- Git also reads the machine-owned `~/.gitconfig`, whose settings take precedence over `~/.config/git/config`
- the Starship prompt intentionally mirrors the former Powerlevel10k two-line Powerline layout
- Powerline separators and module icons require a Nerd Font configured in the terminal
- `EDITOR`, `VISUAL`, and `GIT_EDITOR` default to `nvim`
- completion uses a cache under `${XDG_CACHE_HOME:-$HOME/.cache}/zsh`
- fzf uses `fd` so hidden entries are included while Git-ignored entries and `.git` are excluded
- vi mode is enabled with `jj` returning to command mode
- `/usr/share/nvm/init-nvm.sh` is sourced when present
- `$HOME/.local/bin`, `$HOME/bin`, and an installed `/opt/nvim` are added to `PATH` by the tracked config

## Fuzzy finding

- `Ctrl-t` inserts selected files or directories into the command line
- `Ctrl-r` searches command history
- `Alt-c` changes to a selected directory
- `Ctrl-j` and `Ctrl-k` move down and up through finder results
