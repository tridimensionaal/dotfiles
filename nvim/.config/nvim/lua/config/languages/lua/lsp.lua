return {
  server = "lua_ls",
  mason = "lua-language-server",

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = false,
      },
    },
  },
}
