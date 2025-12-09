-- nvim-lspconfig
return {
  "neovim/nvim-lspconfig",
  dependencies = { "williamboman/mason.nvim", "Saghen/blink.cmp" },
  keys = {
    { "gd", "<cmd>Telescope lsp_definitions<CR>", desc = "Goto Definition" },
    {
      "gi",
      "<cmd>Telescope lsp_implementations<CR>",
      desc = "Goto Implementation",
    },
    {
      "gy",
      "<cmd>Telescope lsp_type_definitions<CR>",
      desc = "Goto T[y]pe Definition",
    },
    { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
    { "K", vim.lsp.buf.hover, desc = "Hover" },
    { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
  },
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    ---@type vim.diagnostic.Opts
    diagnostics = {
      virtual_text = {
        spacing = 4,
        source = "if_many",
      },
      severity_sort = true,
    },
    servers = {
      lua_ls = {
        log_level = 0,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
            doc = {
              privateName = { "^_" },
            },
            hint = {
              enable = true,
              arrrayIndex = "Disable",
            },
          },
        },
      },
      bashls = { filetypes = { "sh", "zsh", "bash" } },
    },
  },
  config = function(_, opts)
    for server, config in pairs(opts.servers) do
      config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
      vim.lsp.enable(server)
      vim.lsp.config(server, config)
    end

    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
  end,
}
