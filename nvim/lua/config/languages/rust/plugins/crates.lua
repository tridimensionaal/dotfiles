return {
  "saecki/crates.nvim",
  tag = "stable",
  ft = { "toml" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("crates").setup()
  end,
}
