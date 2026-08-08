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

local function enable_prose_wrapping()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
end

local function reset_prose_wrapping()
  vim.cmd("setlocal wrap< linebreak<")
end

local prose_wrapping_group = augroup("ProseWrapping", { clear = true })
autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx", "text" },
  callback = function()
    enable_prose_wrapping()

    local undo = "setlocal wrap< linebreak<"
    vim.b.undo_ftplugin = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. " | " .. undo) or undo
  end,
  group = prose_wrapping_group,
})

autocmd({ "BufEnter", "BufLeave" }, {
  pattern = "*",
  callback = function(event)
    if not prose_filetypes[vim.bo.filetype] then
      return
    end

    if event.event == "BufEnter" then
      enable_prose_wrapping()
    else
      reset_prose_wrapping()
    end
  end,
  group = prose_wrapping_group,
})
