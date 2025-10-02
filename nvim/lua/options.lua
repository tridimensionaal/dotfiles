vim.g.mapleader = " "

local opt = vim.opt

-- clipboard
opt.clipboard:append("unnamedplus")

-- text
opt.encoding = "utf-8"

-- indent 
local indent = 4
opt.autoindent = true 
opt.expandtab = true 
opt.shiftwidth = indent 
opt.smartindent = true 
opt.tabstop = indent -- insert 2 spaces for a tab
    

-- numbers
opt.number = true
opt.relativenumber = true

-- style
opt.cursorline = true 
opt.termguicolors = true -- enable 24-bit RGB colors


-- perfomance
-- remember N lines in history
opt.history = 100 -- keep 100 lines of history
opt.redrawtime = 1500
opt.timeoutlen = 200 -- time to wait for a mapped sequence to complete (in milliseconds)
opt.ttimeoutlen = 10
opt.updatetime = 100 -- signify default updatetime 4000ms is not good for async update
