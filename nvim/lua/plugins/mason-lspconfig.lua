return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = function()
    local servers = require("config.lsp.servers")
    return {
      ensure_installed = vim.tbl_keys(servers),
      automatic_installation = true,
      automatic_enable = false,
    }
  end,
}
