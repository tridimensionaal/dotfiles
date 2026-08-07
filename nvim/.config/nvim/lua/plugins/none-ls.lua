return {
  "nvimtools/none-ls.nvim",
  main = "null-ls",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function()
    return require("config.none-ls")
  end,
}
