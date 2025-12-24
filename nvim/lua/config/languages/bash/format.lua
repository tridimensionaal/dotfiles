return {
  sources = function(null_ls)
    return {
      null_ls.builtins.formatting.shfmt,
    }
  end,
  tools = { "shfmt" },
}
