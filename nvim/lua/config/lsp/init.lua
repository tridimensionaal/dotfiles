local capabilities = require("config.lsp.capabilities")
local servers = require("config.lsp.servers")

for name, opts in pairs(servers) do
  opts.capabilities = capabilities
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
