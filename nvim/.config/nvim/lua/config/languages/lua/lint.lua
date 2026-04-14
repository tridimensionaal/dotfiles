
-- config/languages/lua/lint.lua
return {
  sources = function(null_ls)
    return {
      null_ls.builtins.diagnostics.selene,
    }
  end,
  tools = { "selene" },
}

