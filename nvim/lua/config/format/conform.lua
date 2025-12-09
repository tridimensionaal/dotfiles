local registry = require("config.format.registry")

require("conform").setup({
  formatters_by_ft = registry.formatters_by_ft,
  formatters = registry.formatters,
  format_on_save = function()
    return vim.v.cmdbang ~= 1 and {}
  end,
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },
})
