return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  event = "VeryLazy",

  config = function()
    local languages = require("config.languages")

    local ensure = {}

    for _, lang in pairs(languages) do
      if lang.lsp and type(lang.lsp.server) == "string" then
        table.insert(ensure, lang.lsp.server)
      end

      if lang.format and lang.format.tools then
        vim.list_extend(ensure, lang.format.tools)
      end

      if lang.lint and lang.lint.tools then
        vim.list_extend(ensure, lang.lint.tools)
      end
    end

    require("mason-tool-installer").setup({
      ensure_installed = ensure,
      auto_update = false,
      run_on_start = true,
    })
  end,
}
