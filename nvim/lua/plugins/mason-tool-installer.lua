return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  event = "VeryLazy",
  cmd = {
    "MasonToolsInstall",
    "MasonToolsInstallSync",
    "MasonToolsUpdate",
    "MasonToolsUpdateSync",
    "MasonToolsClean",
  },
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = function()
    local ensure = {}

    local linters = require("config.tools.linters")
    local formatters = require("config.tools.formatters")
    local lsp_servers = require("config.tools.lsp.servers")

    for _, group in ipairs({ linters, formatters }) do
      for _, lang in pairs(group) do
        if lang.tools then
          vim.list_extend(ensure, lang.tools)
        end
      end
    end

    vim.list_extend(ensure, vim.tbl_keys(lsp_servers))

    return {
      ensure_installed = ensure,
      auto_update = false,
      run_on_start = true,
    }
  end,
}
