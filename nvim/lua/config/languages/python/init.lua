local M = {}
local ok_lsp, lsp = pcall(require, "config.languages.python.lsp")
local ok_treesitter, treesitter = pcall(require, "config.languages.python.treesitter")

M.lsp = ok_lsp and lsp or nil
M.treesitter = ok_treesitter and treesitter or nil

return M
