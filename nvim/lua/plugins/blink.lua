return {
  "Saghen/blink.cmp",
  dependencies = {
    "neovim/nvim-lspconfig",
    "L3MON4D3/LuaSnip",
  },
  opts = {
    keymap = { preset = "default" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
  end,
}
