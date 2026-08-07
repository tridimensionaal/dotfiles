local M = {}

function M.enable()
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
end

return M
