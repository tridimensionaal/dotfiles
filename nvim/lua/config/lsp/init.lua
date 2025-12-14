local M = {}

function M.setup()
  local languages = require("config.languages")
  local mappings = require("config.lsp.mappings")
  local capabilities = require("config.lsp.capabilities")

  -- Global LSP mappings / diagnostics
  mappings.setup()

  for _, lang in pairs(languages) do
    if lang.lsp then
      local lsp = lang.lsp

      vim.lsp.config(lsp.server, {
        capabilities = capabilities,
        on_attach = mappings.on_attach,
        settings = lsp.settings,
        filetypes = lsp.filetypes,
      })

      vim.lsp.enable(lsp.server)
    end
  end
end

return M
