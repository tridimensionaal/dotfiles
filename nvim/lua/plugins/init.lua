-- plugins/init.lua
local builtin_plugins = {
    -- plenary
  { lazy = true, "nvim-lua/plenary.nvim" },

  -- for line status line 
  { "echasnovski/mini.statusline", opts = {} },

 "EdenEast/nightfox.nvim",

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {},
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "plugins.configs.treesitter"
    end,
  },

  --
  {
      "mason-org/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
      build = ":MasonUpdate",
      config = function() require "plugins.configs.mason" end,
    },

  -- for tabs
  {
    "akinsho/bufferline.nvim",
    opts = require "plugins.configs.bufferline",
  },
 {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
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
