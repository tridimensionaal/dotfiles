-- plugins/init.lua
local builtin_plugins = {
  { lazy = true, "nvim-lua/plenary.nvim" },

  { "echasnovski/mini.statusline", opts = {} },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "plugins.configs.treesitter"
    end,
  },

}

require("lazy").setup {
    spec = { builtin_plugins },
    lockfile = vim.fn.stdpath "config" .. "/lazy-lock.json",
    defaults = {
        lazy = false,
        version = nil,
    },
    ui = {
        icons = {
            ft = "",
            lazy = "󰂠",
            loaded = "",
            not_loaded = "",
        },
    },
    performance = {
        cache = {
            enabled = true,
        },
    },
    state = vim.fn.stdpath "state" .. "/lazy/state.json",
}
