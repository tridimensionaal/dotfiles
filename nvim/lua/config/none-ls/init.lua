local null_ls = require("null-ls")
local linters = require("config.tools.linters")
local formatters = require("config.tools.formatters")

local function collect_sources(collection)
  local acc = {}
  for _, lang in pairs(collection) do
    if type(lang.sources) == "function" then
      vim.list_extend(acc, lang.sources(null_ls))
    elseif lang.sources then
      vim.list_extend(acc, lang.sources)
    end
  end
  return acc
end

local sources = {}
vim.list_extend(sources, collect_sources(linters))
vim.list_extend(sources, collect_sources(formatters))

local format_augroup = vim.api.nvim_create_augroup("NoneLsFormatOnSave", {})

null_ls.setup({
  sources = sources,
  on_attach = function(client, bufnr)
    if not client.supports_method("textDocument/formatting") then
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
