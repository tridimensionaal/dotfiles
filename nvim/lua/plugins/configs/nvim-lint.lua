local function config()
  -- Map each filetype to a list of the config filenames to set up linters (NOT the Mason package name)
  -- See available filenames: https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
  require("lint").linters_by_ft = {
    -- python = { "ruff" },
  }
    local api = vim.api
    api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
      group = api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        if vim.bo.modifiable then
          require("lint").try_lint()
        end
      end,
    })
end

return config
