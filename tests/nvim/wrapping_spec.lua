local config_root = assert(vim.env.NVIM_CONFIG_ROOT, "NVIM_CONFIG_ROOT must point to nvim/.config/nvim")

vim.opt.runtimepath:prepend(config_root)
vim.opt.runtimepath:append(vim.fs.joinpath(config_root, "after"))
vim.cmd("filetype plugin on")

local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(("%s: expected %s, got %s"):format(message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function open_filetype(filetype)
  vim.cmd("enew!")
  vim.opt_local.wrap = false
  vim.opt_local.linebreak = false
  vim.bo.filetype = filetype
end

open_filetype("markdown")
assert_equal(vim.wo.wrap, true, "Markdown wrap")
assert_equal(vim.wo.linebreak, true, "Markdown word-boundary wrapping")
assert_equal(vim.bo.shiftwidth, 2, "Markdown indentation")

open_filetype("text")
assert_equal(vim.wo.wrap, true, "text wrap")
assert_equal(vim.wo.linebreak, true, "text word-boundary wrapping")

vim.cmd("qall!")
