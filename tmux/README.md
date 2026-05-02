# Tmux

The main tmux config lives at `~/.config/tmux/tmux.conf`.

Install it with:

```sh
./install.sh tmux
```

`~/.tmux.conf` is kept as a small compatibility shim that sources the XDG config, so tmux still picks up the config without extra wrapper logic.

## TPM

The config uses TPM and plugin-managed features.

- clone TPM at `~/.tmux/plugins/tpm`
- then either run `~/.tmux/plugins/tpm/bin/install_plugins` or open tmux and press `Ctrl-Space` followed by `Shift-I`
- plugin state is intentionally kept under `~/.tmux/plugins/`, outside the Stow-managed config tree

Without TPM, basic tmux settings still load, but theme and plugin features will not.

## Notable settings

- prefix is `Ctrl+Space`
- pane navigation uses `h/j/k/l`
- splits and new windows start in the current pane directory
- TPM plugins are enabled for sensible defaults, vim navigation, Dracula, and yank
