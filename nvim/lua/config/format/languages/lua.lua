return {
  formatters = { "stylua" },
  config = {
    stylua = {
      prepend_args = {
        "--column-width=120",
        "--indent-type=Spaces",
        "--indent-width=2",
        "--line-endings=Unix",
      },
    },
  },
}
