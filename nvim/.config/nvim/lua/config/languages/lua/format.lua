return {
  sources = function(null_ls)
    return {
      null_ls.builtins.formatting.stylua.with({
        extra_args = {
          "--column-width=120",
          "--indent-type=Spaces",
          "--indent-width=2",
          "--line-endings=Unix",
        },
      }),
    }
  end,
  tools = { "stylua" },
}
