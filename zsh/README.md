# zsh config

Files in this directory are meant to be symlinked into `$HOME`.

## Files
- `.zshrc`: main Zsh configuration, loads Powerlevel10k and user settings.
- `.zsh_aliases`: optional alias definitions, sourced by `.zshrc` if present.
- `.p10k.zsh`: Powerlevel10k prompt configuration.

## Setup
```sh
ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
ln -sfn "$PWD/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
```

## TODO
