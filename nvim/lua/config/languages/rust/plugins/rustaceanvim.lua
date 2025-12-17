local rust_lsp = require("config.languages.rust.lsp")

return {
  "mrcjkb/rustaceanvim",
  version = "^6",
  lazy = false,
  ft = { "rust" },
  config = function()
    local format_augroup = vim.api.nvim_create_augroup("RustaceanvimFormatOnSave", {})
    local capabilities = require("config.lsp.capabilities")
    local settings = vim.deepcopy(rust_lsp.settings or {})

    vim.g.rustaceanvim = {
      server = {
        capabilities = capabilities,
        settings = settings,
        default_settings = settings,
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

              vim.lsp.buf.format({
                bufnr = bufnr,
                timeout_ms = 3000,
                filter = function(c)
                  return c.name == "rust_analyzer"
                end,
              })
            end,
          })
        end,
      },
    }
  end,
}
