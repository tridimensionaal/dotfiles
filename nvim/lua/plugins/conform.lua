return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("config.format.conform")
  end,
}
