vim.g.mapleader = " "

local map = vim.keymap.set

map("i", "jj", "<ESC>")

--
map("n", "<leader>w", "<cmd>w<CR>", { desc = "save current buffer" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "" })

map("n", "<leader>h", "<C-w>h", { desc = "switch window left" })
map("n", "<leader>l", "<C-w>l", { desc = "switch window right" })
map("n", "<leader>k", "<C-w>k", { desc = "switch window up" })
map("n", "<leader>j", "<C-w>j", { desc = "switch window down" })
