return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",

  event = "VeryLazy",

  keys = {
    -- pick buffer
    { "<leader>bb", "<cmd>BufferLinePick<CR>", desc = "Select buffer" },
    -- close current buffer
    { "<leader>c", "<cmd>bdelete | bprevious <cr>", { desc = "close current buffer" } },
  },

  opts = {
    options = {
      themable = true,

      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
    },
  },
}
