local config_root = assert(vim.env.NVIM_CONFIG_ROOT, "NVIM_CONFIG_ROOT must point to nvim/.config/nvim")

vim.opt.runtimepath:prepend(config_root)

package.loaded["null-ls"] = {}
package.loaded["config.languages"] = {}
package.loaded["config.none-ls"] = nil

local options = require("config.none-ls")
local client = {}
local bufnr = vim.api.nvim_get_current_buf()
local clear_options
local create_options

function client:supports_method(method)
  assert(self == client, "Client:supports_method must be called with method syntax")
  assert(method == "textDocument/formatting", "unexpected LSP method")
  return true
end

vim.api.nvim_clear_autocmds = function(opts)
  clear_options = opts
end

vim.api.nvim_create_autocmd = function(_, opts)
  create_options = opts
end

vim.bo[bufnr].filetype = "lua"
options.on_attach(client, bufnr)

assert(clear_options.buf == bufnr and clear_options.buffer == nil, "clear_autocmds must use its current buf key")
assert(create_options.buf == bufnr and create_options.buffer == nil, "create_autocmd must use its current buf key")

vim.cmd("qall!")
