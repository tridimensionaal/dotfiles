-- linter
return {
  "mfussenegger/nvim-lint",
  event = { "BufNewFile", "BufReadPre", "BufWritePost" },
  config = function()
    require("config.lint.nvim-lint")
  end,
}
