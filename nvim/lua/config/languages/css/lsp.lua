return {
  servers = {
    {
      server = "cssls",
      filetypes = { "css", "scss", "less" },
      settings = {
        css = {
          validate = true,
          format = { enable = false },
        },
        scss = {
          validate = true,
          format = { enable = false },
        },
        less = {
          validate = true,
          format = { enable = false },
        },
      },
    },
    {
      server = "tailwindcss",
      filetypes = {
        "astro",
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "svelte",
        "typescript",
        "typescriptreact",
        "vue",
      },
      root_markers = {
        "tailwind.config.js",
        "tailwind.config.cjs",
        "tailwind.config.mjs",
        "tailwind.config.ts",
        "postcss.config.js",
        "postcss.config.cjs",
        "postcss.config.mjs",
        "postcss.config.ts",
        "package.json",
        ".git",
      },
    },
  },
}
