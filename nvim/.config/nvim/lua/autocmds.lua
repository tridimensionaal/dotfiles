local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ timeout = 170 })
  end,
  group = highlight_group,
})

local prose_filetypes = {
  markdown = true,
  ["markdown.mdx"] = true,
  text = true,
}

local prose_wrapping_group = augroup("ProseWrapping", { clear = true })
autocmd({ "BufEnter", "FileType" }, {
  pattern = "*",
  callback = function()
    local enabled = prose_filetypes[vim.bo.filetype] == true
    vim.wo.wrap = enabled
    vim.wo.linebreak = enabled
  end,
  group = prose_wrapping_group,
})
