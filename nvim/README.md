# Neovim

This package installs the Neovim config into `~/.config/nvim`.

## Notes

- `init.lua` lives at `~/.config/nvim/init.lua`
- language-specific modules live under `~/.config/nvim/lua/config/languages/`
- filetype overrides live under `~/.config/nvim/after/ftplugin/`
- plugin management is handled by `lazy.nvim`
- editor tooling installation is handled by Mason plus `mason-tool-installer`

The package also keeps repo-only files such as `selene.toml` and `neovim-setup.png`, but those are ignored by Stow and are not linked into `$HOME`.
