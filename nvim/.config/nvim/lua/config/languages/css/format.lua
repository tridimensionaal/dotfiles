return {
  sources = function(null_ls)
    return {
      null_ls.builtins.formatting.prettierd.with({
        filetypes = { "css", "scss", "less" },
        extra_args = { "--tab-width=2", "--no-use-tabs" },
      }),
    }
  end,
  tools = { "prettierd" },
}
