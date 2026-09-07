local M = {}

function M.setup()
  local api = vim.api

  api.nvim_create_autocmd("LspAttach", {
    group = api.nvim_create_augroup("LspKeymaps", { clear = true }),
    callback = function(event)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buf = event.buf, silent = true, desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buf = event.buf, silent = true, desc = "Go to declaration" })
      vim.keymap.set(
        "n",
        "gi",
        vim.lsp.buf.implementation,
        { buf = event.buf, silent = true, desc = "Go to implementation" }
      )
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { buf = event.buf, silent = true, desc = "Find references" })
      vim.keymap.set(
        "n",
        "gy",
        vim.lsp.buf.type_definition,
        { buf = event.buf, silent = true, desc = "Go to type definition" }
      )
      vim.keymap.set("n", "K", function()
        local max_width = math.max(20, math.floor(vim.api.nvim_win_get_width(0) * 0.5))
        vim.lsp.buf.hover({ max_width = max_width, border = "rounded" })
      end, { buf = event.buf, silent = true, desc = "Show documentation" })
    end,
  })
end

return M
