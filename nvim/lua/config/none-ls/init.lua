local null_ls = require("null-ls")
local languages = require("config.languages")

--- collect lint and format sources from all language modules
---
--- each language can expose:
---1) linter: `lang.lint.sources(null_ls)` for diagnostics sources
---2) formatter: `lang.format.sources(null_ls)` for formatting sources
---
--- returned value is passed directly to `null_ls.setup({ sources = ... })`
--- @return table sources flat list of none-ls source objects.
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

--- check whether a buffer currently has a `null-ls` formatting client attached
---
--- used to prefer null-ls when multiple LSP clients can format the same buffer,
--- which avoids formatter conflicts (e.g. `prettierd` vs language-server format)
--- @param bufnr integer Buffer number.
--- @return boolean has_null_ls True if `null-ls` can format this buffer
--- if null-ls can format this buffer, we prefer it to avoid formatter conflicts
--- with language servers that also expose formatting
local function has_null_ls_formatter(bufnr)
  for _, lsp_client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })) do
    if lsp_client.name == "null-ls" then
      return true
    end
  end

  return false
end

null_ls.setup({
  debug = true,
  log_level = "debug",
  sources = collect_sources(),

  --- attach handler per buffer after a none-ls client attaches.
  ---
  --- when formatting is supported, this registers a `BufWritePre` autocmd that:
  --- 1) skips `:w!` writes (`cmdbang`) to preserve current behavior
  --- 2) prefers `null-ls` formatter when available
  --- 3) falls back to default `vim.lsp.buf.format` selection otherwise
  ---
  --- rust is intentionally excluded because formatting is handled elsewhere
  --- `rustaceanvim` in this config.
  --- TODO: refactor to delete that hardcoded rust behavior
  ---
  --- @param client vim.lsp.Client attached none-ls client.
  --- @param bufnr integer buffer number.
  ---
  on_attach = function(client, bufnr)
    if not client.supports_method("textDocument/formatting") then
      return
    end

    -- hardcoded for rust because it uses rustaceanvim
    if vim.bo[bufnr].filetype == "rust" then
      return
    end

    vim.api.nvim_clear_autocmds({ group = format_augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_augroup,
      buffer = bufnr,
      -- run format-before-save for the current buffer
      callback = function()
        if vim.v.cmdbang == 1 then
          return
        end

        local format_opts = { bufnr = bufnr, timeout_ms = 3000 }
        if has_null_ls_formatter(bufnr) then
          -- force formatting through null-ls when present
          format_opts.filter = function(lsp_client)
            return lsp_client.name == "null-ls"
          end
        end

        vim.lsp.buf.format(format_opts)
      end,
    })
  end,
})
