local config_root = assert(vim.env.NVIM_CONFIG_ROOT, "NVIM_CONFIG_ROOT must point to nvim/.config/nvim")

vim.opt.runtimepath:prepend(config_root)

package.loaded["null-ls"] = {}
package.loaded["config.languages"] = {}
package.loaded["config.none-ls"] = nil

local options = require("config.none-ls")
local client = {}

function client:supports_method(method)
  assert(self == client, "Client:supports_method must be called with method syntax")
  assert(method == "textDocument/formatting", "unexpected LSP method")
  return false
end

options.on_attach(client, vim.api.nvim_get_current_buf())

vim.cmd("qall!")
