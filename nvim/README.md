# Neovim config

<p align="center">
  <img src="./neovim-setup.png" width="800">
</p>
<p align="center">
  <em> Personal Neovim setup. </em>
</p>

## Notes
- Uses Lazy.nvim for plugin management (`lua/lazy_init.lua`).
- Plugin specs live in `lua/plugins/`.
- Language-specific extras are pulled from `lua/config/languages`.
- Keymaps, options, and autocmds are in `lua/mappings.lua`, `lua/options.lua`, and `lua/autocmds.lua`.

## Project structure
- `init.lua`: entry point, loads core modules and optional `custom` module.
- `lua/lazy_init.lua`: bootstraps Lazy.nvim and loads plugin specs.
- `lua/plugins/`: one plugin spec per file (Lazy.nvim format).
- `lua/config/languages/`: per-language config (LSP, lint, format, options) plus optional language plugins.
- `lua/config/lsp/`: shared LSP config (capabilities, mappings, handlers).
- `lua/config/ui/`: UI config (statusline, bufferline, colors).
- `lua/mappings.lua`, `lua/options.lua`, `lua/autocmds.lua`: core Neovim setup.

## How to add a plugin
1. Create a new file in `lua/plugins/` (example: `lua/plugins/todo.lua`).
2. Return a Lazy.nvim spec table from that file.

Example:
```lua
-- lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "lua", "python", "rust", "markdown" },
    highlight = { enable = true },
  },
}
```
## How to add a language config

1. Create a new folder under `lua/config/languages/<lang>/`.

2. Add an `init.lua` that returns a module with any of: `lsp`, `format`, `lint`, `options`, `plugins`.
   Each submodule is optional, and `pcall` is used so missing files don't error.
   Example:

```lua
-- lua/config/languages/rust/init.lua
local M = {}

local ok_lsp, rust_lsp = pcall(require, "config.languages.rust.lsp")
local ok_plugins, plugins = pcall(require, "config.languages.rust.plugins")

if ok_lsp and type(rust_lsp) == "table" then
  rust_lsp.skip_builtin = true
  M.lsp = rust_lsp
end

M.plugins = ok_plugins and plugins or nil

return M
```

3. Add `lsp.lua`, `lint.lua`, and/or `format.lua` in that language folder depending on what you need.
   Each file is optional; only include what you plan to configure.

4. Add the language name to `lua/config/languages/init.lua` explicitly.
  Example:
```lua
local M = {}

M.lua = require("config.languages.lua")
M.python = require("config.languages.python")
M.rust = require("config.languages.rust")
M.markdown = require("config.languages.markdown")

return M
```

5. Add the Treesitter parser name to `lua/plugins/treesitter.lua` under `opts.ensure_installed`.
   This is currently hardcoded there; the long-term goal is to pull this list from
   `lua/config/languages/<lang>/` instead.

6. Optional: if the language needs extra plugins, add `lua/config/languages/<lang>/plugins/init.lua`
   and set `M.plugins` in the language `init.lua`. These specs are merged into the main Lazy spec.

```lua
-- lua/config/languages/rust/plugins/init.lua
return {
  require("config.languages.rust.plugins.rustaceanvim"),
  require("config.languages.rust.plugins.crates"),
}
```

## TODO

- [ ] Replace the custom diagnostics plugin with a more established plugin.
- [ ] Add TODO plugin ([folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim))
- [ ] Derive Treesitter parsers from `lua/config/languages/<lang>/` instead of hardcoding in `lua/plugins/treesitter.lua`.


## References and inspirations

- [AstroNvim/AstroNvim](https://github.com/AstroNvim/AstroNvim)
- [tjdevries/advent-of-nvim](https://github.com/tjdevries/advent-of-nvim)
- [asyncedd/dots.nvim](https://github.com/asyncedd/dots.nvim)
- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [SnaxVim/SnaxVim](https://github.com/SnaxVim/SnaxVim)
- [j4de/nvim](https://codeberg.org/j4de/nvim/src/branch/master)
