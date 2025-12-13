return {
  sources = function(null_ls)
    return {
      null_ls.builtins.diagnostics.ruff,
    }
  end,
  tools = { "ruff" },
}
