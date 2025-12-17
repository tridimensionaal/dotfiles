local null_ls = require("null-ls")
local languages = require("config.languages")

local function collect_sources()
  local acc = {}

  for _, lang in pairs(languages) do
    if lang.lint and type(lang.lint.sources) == "function" then
      vim.list_extend(acc, lang.lint.sources(null_ls))
    end

    if lang.format and type(lang.format.sources) == "function" then
      vim.list_extend(acc, lang.format.sources(null_ls))
    end
  end

  return acc
end

local format_augroup = vim.api.nvim_create_augroup("NoneLsFormatOnSave", {})

null_ls.setup({
  sources = collect_sources(),

  on_attach = function(client, bufnr)
    if not client.supports_method("textDocument/formatting") then
      return
    end

    -- Let rustaceanvim handle Rust formatting to avoid double formatters.
    if vim.bo[bufnr].filetype == "rust" then
      return
    end

    vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_augroup,
      buffer = bufnr,
      callback = function()
        if vim.v.cmdbang == 1 then
          return
        end
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
      end,
    })
  end,
})
