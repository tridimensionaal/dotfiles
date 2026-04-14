vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = false,
  float = {
    border = "rounded",
    focusable = true,
    close_events = { "BufHidden", "InsertEnter" },
    header = "",
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LocalDiagnostics", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    -- to open diag window
    vim.keymap.set("n", "<leader>ld", function()
      local win = vim.diagnostic.open_float(nil, { focus = true, scope = "cursor" })
      if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
      end
    end, opts)

    -- move between diagnostics
    vim.keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, opts)
  end,
})
