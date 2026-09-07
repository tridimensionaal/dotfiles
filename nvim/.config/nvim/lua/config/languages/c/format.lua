return {
  sources = function(null_ls)
    return {
      null_ls.builtins.formatting.clang_format.with({
        filetypes = { "c" },
      }),
    }
  end,
  tools = { "clang-format" },
}
