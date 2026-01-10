return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",

  event = "VeryLazy",

  keys = {
    -- pick buffer
    { "<leader>bb", "<cmd>BufferLinePick<CR>", desc = "Select buffer" },
    -- close current buffer
    { "<leader>c", "<cmd>bdelete! | bprevious <cr>", { desc = "close current buffer" } },

    { "<leader>n", "<cmd>enew<CR>", desc = "create new buffer" },
  },

  opts = function()
    return require("config.ui.bufferline")
  end,
}
