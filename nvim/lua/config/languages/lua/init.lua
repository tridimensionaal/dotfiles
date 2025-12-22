local M = {}

local ok_options, options = pcall(require, "config.languages.lua.options")
local ok_format, format = pcall(require, "config.languages.lua.format")
local ok_lint, lint = pcall(require, "config.languages.lua.lint")
local ok_lsp, lsp = pcall(require, "config.languages.lua.lsp")

M.options = ok_options and options or nil
M.format = ok_format and format or nil
M.lint = ok_lint and lint or nil
M.lsp = ok_lsp and lsp or nil

return M
