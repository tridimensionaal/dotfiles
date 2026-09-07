# Neovim

The Neovim config lives under `~/.config/nvim`.
It targets Neovim 0.12 or newer.

Install it with:

```sh
./install.sh nvim
```

## Configuration layout

This config is a small framework built from ordinary Lua configuration files.
Global settings define shared editor behavior, while language modules keep each
language's configuration together. The aim is to keep the setup easy to follow
and change, with little abstraction over Neovim and its plugins.

- `init.lua` lives at `~/.config/nvim/init.lua`
- core editor modules live under `~/.config/nvim/lua/`
- language-specific modules live under `~/.config/nvim/lua/config/languages/`
- plugin specs live under `~/.config/nvim/lua/plugins/`
- filetype overrides live under `~/.config/nvim/after/ftplugin/`
- post-plugin setup lives under `~/.config/nvim/after/plugin/`

Languages are registered in `lua/config/languages/init.lua`. Shared setup code
reads their LSP, formatter, linter, parser, and tool declarations and connects
them to the relevant plugins. Language modules only include the parts they need;
filetype overrides apply buffer-local settings through Neovim's `after/ftplugin/`.

## Tooling

- plugin management is handled by `lazy.nvim`
- validated plugin revisions are recorded in `lazy-lock.json`
- editor tooling installation is handled by Mason plus `mason-tool-installer`

The complete 0.12 API and plugin review, including the decision for every
configured dependency, is in [PLUGIN_AUDIT.md](PLUGIN_AUDIT.md).

The package also keeps repo-only lint configuration such as `selene.toml` and
`neovim.yml`, but those files are ignored by Stow and are not linked into
`$HOME`.

First launch may need network access so Lazy.nvim, Mason, and Treesitter can bootstrap plugins, tool binaries, and parsers.
