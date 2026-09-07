-- for autocompletation

return {
  "Saghen/blink.cmp",
  version = "1.*", -- use tagged releases with prebuilt fuzzy matcher binaries
  dependencies = { "not-manu/filemention.nvim" },
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
      default = { "lsp", "path", "snippets", "buffer", "filemention" },
      providers = {
        filemention = {
          name = "Files",
          module = "filemention.sources.blink",
          opts = {
            -- CLI prompt files may live in /tmp; search the working project.
            root = "cwd",
            filetypes = { "markdown", "text", "" },
            include_hidden = true,
            -- Let Blink filter the full project instead of the first 500 paths.
            max_items = math.huge,
          },
        },
      },
    },
  },
}
