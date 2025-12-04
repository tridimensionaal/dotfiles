-- linter
return {
  "mfussenegger/nvim-lint",
  event = { "BufNewFile", "BufReadPre", "BufWritePost" },

  config = function()
    local lint = require("lint")

    -- Map filetypes → linter names (from nvim-lint, NOT Mason package names)
    lint.linters_by_ft = {
      -- python = { "ruff" },
    }

    local api = vim.api
    api.nvim_create_autocmd(
      { "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" },
      {
        group = api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      }
    )
  end,
}

