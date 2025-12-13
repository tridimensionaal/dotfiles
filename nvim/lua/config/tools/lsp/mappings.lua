local M = {}

function M.setup()
  local api = vim.api

  api.nvim_create_autocmd("LspAttach", {
    group = api.nvim_create_augroup("LspKeymaps", { clear = true }),
    callback = function(event)
      local opts = { buffer = event.buf, silent = true }

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    end,
  })
end

return M
