-- for autocompletation

return {
  "Saghen/blink.cmp",
  version = "1.*", -- use tagged releases with prebuilt fuzzy matcher binaries
  opts = {
    keymap = {
      preset = "default",

      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-k>"] = { "scroll_documentation_up", "fallback" },
      ["<C-j>"] = { "scroll_documentation_down", "fallback" },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
