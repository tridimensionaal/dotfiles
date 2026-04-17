return {
  "Mofiqul/dracula.nvim",
  priority = 1000,
  config = function()
    require("config.ui.colors").apply()
  end,
}
