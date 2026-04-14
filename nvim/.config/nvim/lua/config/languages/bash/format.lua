return {
  sources = function(null_ls)
    return {
      null_ls.builtins.formatting.shfmt.with({
        extra_args = { "-i", "4" },
      }),
    }
  end,
  tools = { "shfmt" },
}
