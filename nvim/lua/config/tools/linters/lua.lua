return {
  sources = function(null_ls)
    return {
      null_ls.builtins.diagnostics.luacheck,
    }
  end,
  tools = { "luacheck" },
}
