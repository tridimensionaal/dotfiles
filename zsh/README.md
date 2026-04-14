# Zsh

This package keeps the main Zsh config under `~/.config/zsh` and installs one top-level file:

- `~/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"`

Tracked config files:

- `~/.config/zsh/.zshrc`
- `~/.config/zsh/.zsh_aliases`
- `~/.config/zsh/.p10k.zsh`

## Notes

- history is stored at `${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history`
- the Powerlevel10k prompt config is loaded from `ZDOTDIR`
- the `Bash-scripts-for-daily-task` integration is optional and only loads when `${BASH_SCRIPTS_INIT}` or its default path exists
