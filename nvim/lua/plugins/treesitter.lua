-- nvim-treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",

  opts = {
    ensure_installed = {
      "bash",
      "git_config",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "ssh_config",
      "toml",
      "vim",
      "vimdoc",
      "yaml",
      "python",
      "rust",
    },

    highlight = {
      enable = true,
      use_languagetree = true,
    },

    indent = {
      enable = true,
    },

    autotag = {
      enable = true,
    },

    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },

    refactor = {
      highlight_definitions = { enable = true },
      highlight_current_scope = { enable = false },
    },
  },
}
