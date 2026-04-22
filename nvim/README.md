# Neovim

The Neovim config lives under `~/.config/nvim`.

## Notes

- `init.lua` lives at `~/.config/nvim/init.lua`
- core editor modules live under `~/.config/nvim/lua/`
- language-specific modules live under `~/.config/nvim/lua/config/languages/`
- plugin specs live under `~/.config/nvim/lua/plugins/`
- filetype overrides live under `~/.config/nvim/after/ftplugin/`
- post-plugin setup lives under `~/.config/nvim/after/plugin/`
- plugin management is handled by `lazy.nvim`
- editor tooling installation is handled by Mason plus `mason-tool-installer`

The package also keeps repo-only lint configuration such as `selene.toml`, but those files are ignored by Stow and are not linked into `$HOME`.
