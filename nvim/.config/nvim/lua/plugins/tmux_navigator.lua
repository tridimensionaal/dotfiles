return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Navigate left" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Navigate down" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Navigate up" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Navigate right" },
    { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Navigate to previous pane" },
  },
}
