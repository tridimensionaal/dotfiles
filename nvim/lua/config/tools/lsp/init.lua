require("config.tools.lsp.mappings").setup()

local capabilities = require("config.tools.lsp.capabilities")
local servers = require("config.tools.lsp.servers")

for name, opts in pairs(servers) do
  opts.capabilities = capabilities
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
