local M = {}
local ok_lsp, lsp = pcall(require, "config.languages.python.lsp")

M.lsp = ok_lsp and lsp or nil

return M
