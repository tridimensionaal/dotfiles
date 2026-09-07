local M = {}

-- Treat .h files as C headers instead of Neovim's default C++.
vim.g.c_syntax_for_h = 1

local ok_options, options = pcall(require, "config.languages.c.options")
local ok_format, format = pcall(require, "config.languages.c.format")
local ok_lint, lint = pcall(require, "config.languages.c.lint")
local ok_lsp, lsp = pcall(require, "config.languages.c.lsp")
local ok_treesitter, treesitter = pcall(require, "config.languages.c.treesitter")

M.options = ok_options and options or nil
M.format = ok_format and format or nil
M.lint = ok_lint and lint or nil
M.lsp = ok_lsp and lsp or nil
M.treesitter = ok_treesitter and treesitter or nil

return M
