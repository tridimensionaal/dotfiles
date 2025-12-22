local M = {}
local ok_lsp, lsp = pcall(require, "config.languages.markdown.lsp")

M.lsp = ok_lsp and lsp or nil

return M
