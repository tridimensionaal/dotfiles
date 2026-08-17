return {
  "ibhagwan/fzf-lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Find text" },
    { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "Find help" },
    { "<leader>fr", "<cmd>FzfLua resume<CR>", desc = "Resume finder" },
  },
  opts = {
    { "fzf-native", "hide" },
    files = {
      hidden = true,
      no_ignore = false,
      fd_opts = "--color=never --type f --type l --exclude .git",
    },
    grep = {
      hidden = true,
      no_ignore = false,
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob '!.git' -e",
    },
  },
}
