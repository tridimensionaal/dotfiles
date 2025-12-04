vim.g.mapleader = " "

local map = vim.keymap.set

map("i", "jj", "<ESC>")

--
map("n", "<leader>w", "<cmd>w<CR>", { desc = "save current buffer" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "save current buffer" })

-- buffers
map("n", "<leader>c", "<cmd>bdelete | bprevious <cr>", { desc = "close current buffer" })
map("n", "<leader>bb", "<cmd>bufferlinepick<cr>", { desc = "choose buffer" })

-- comments
map("n", "<leader>/", "gcc", { desc = "comment line", remap = true })
map("v", "<leader>/", "gc", { desc = "comment visual block", remap = true })

-- tree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle  vimTree sidebar" }) -- open/close
map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh NvimTree" }) -- refresh

map("n", "<leader>h", "<C-w>h", { desc = "switch window left" })
map("n", "<leader>l", "<C-w>l", { desc = "switch window right" })
map("n", "<leader>k", "<C-w>k", { desc = "switch window up" })
map("n", "<leader>j", "<C-w>j", { desc = "switch window down" })
