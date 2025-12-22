local M = {}

local ok_lsp, rust_lsp = pcall(require, "config.languages.rust.lsp")
local ok_plugins, plugins = pcall(require, "config.languages.rust.plugins")

if ok_lsp and type(rust_lsp) == "table" then
  -- rustaceanvim handles rust_analyzer; avoid double-registering via the generic LSP setup.
  rust_lsp.skip_builtin = true
  M.lsp = rust_lsp
end

M.plugins = ok_plugins and plugins or nil

return M
