return {
  server = "clangd",
  mason = "clangd",
  -- clangd includes clang-tidy, so linting needs no separate none-ls source.
  cmd = { "clangd", "--clang-tidy" },
  filetypes = { "c" },
}
