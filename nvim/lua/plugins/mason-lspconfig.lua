return {
  "mason-org/mason-lspconfig.nvim",
  opts = {},
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },

  config = function()
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        -- add more servers here
      },
      automatic_installation = true,
    })

    mason_lspconfig.setup_handlers({
      function(server)
        require("lspconfig")[server].setup({
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        })
      end,
    })
  end,
}
