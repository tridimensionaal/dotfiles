return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  debug = true,
  log_level = "debug",
  config = function()
    require("config.none-ls")
  end,
}
