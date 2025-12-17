local M = {}

local rust_lsp = require("config.languages.rust.lsp")

-- rustaceanvim handles rust_analyzer; avoid double-registering via the generic LSP setup.
rust_lsp.skip_builtin = true

M.lsp = rust_lsp

return M
