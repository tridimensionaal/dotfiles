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
    local opts = { buf = event.buf, silent = true }
    -- to open diag window
    vim.keymap.set("n", "<leader>ld", function()
      local _, win = vim.diagnostic.open_float({ bufnr = event.buf, focus = true, scope = "cursor" })
      if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
      end
    end, opts)

    -- move between diagnostics
    local function jump(count)
      return function()
        vim.diagnostic.jump({
          count = count,
          on_jump = function(diagnostic, bufnr)
            if not diagnostic then
              return
            end

            vim.diagnostic.open_float({ bufnr = bufnr, focus = false, scope = "cursor" })
          end,
        })
      end
    end

    vim.keymap.set("n", "<leader>ln", jump(1), opts)
    vim.keymap.set("n", "<leader>lp", jump(-1), opts)
  end,
})
