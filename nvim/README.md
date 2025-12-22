# Neovim config

Personal Neovim setup.

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
3. Add the language name to `lua/config/languages/init.lua` explicitly.
4. Optional: if the language needs extra plugins, add `lua/config/languages/<lang>/plugins/init.lua`
   and set `M.plugins` in the language `init.lua`. These specs are merged into the main Lazy spec.

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

```lua
-- lua/config/languages/rust/plugins/init.lua
return {
  require("config.languages.rust.plugins.rustaceanvim"),
  require("config.languages.rust.plugins.crates"),
}
```

## References and inspirations
- [AstroNvim](https://github.com/AstroNvim/AstroNvim)
