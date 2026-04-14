local M = {}

function M.setup()
  local treesitter = require("nvim-treesitter")
  local ts = require("config.treesitter.languages")

  -- nvim-treesitter `main` only uses setup for plugin-level config (e.g. install_dir).
  treesitter.setup({})

  local parsers = ts.parsers()
  if #parsers > 0 then
    treesitter.install(parsers)
  end

  -- On `main`, highlighting is a Neovim core feature and must be started per buffer.
  local group = vim.api.nvim_create_augroup("TreeSitterStart", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      ts.start(args.buf)
    end,
  })
end

return M
