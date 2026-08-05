# Zsh

The main Zsh config lives under `~/.config/zsh` with two intentional top-level entries:

- `~/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"`
- `~/.zshrc` collects integrations from installers that do not respect `ZDOTDIR`; the main config sources it

Install it with:

```sh
./install.sh zsh
```

Tracked config files:

- `~/.config/zsh/.zshrc`
- `~/.config/zsh/.zsh_aliases`
- `~/.config/starship.toml`

## Notes

- history is stored at `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history`
- Starship is initialized at the end of the main Zsh config and reads `~/.config/starship.toml`
- `EDITOR`, `VISUAL`, and `GIT_EDITOR` default to `nvim`
- completion uses a cache under `${XDG_CACHE_HOME:-$HOME/.cache}/zsh`
- vi mode is enabled with `jj` returning to command mode
- `/usr/share/nvm/init-nvm.sh` is sourced when present
- the `Bash-scripts-for-daily-task` integration is optional and only loads when `${BASH_SCRIPTS_INIT}` or its default path exists
