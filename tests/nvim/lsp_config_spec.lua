local config_root = assert(vim.env.NVIM_CONFIG_ROOT, "NVIM_CONFIG_ROOT must point to nvim/.config/nvim")

vim.opt.runtimepath:prepend(config_root)

local capabilities = { test_capability = true }
local handlers = { ["test/handler"] = function() end }
local mappings_were_set = false
local registrations = {}
local enabled = {}

package.loaded["config.languages"] = {
  primary = {
    lsp = {
      server = "alpha_ls",
      mason = "alpha-language-server",
      handlers = handlers,
      settings = { alpha = { enabled = true } },
    },
  },
  secondary = {
    lsp = {
      servers = {
        {
          server = "beta_ls",
          mason = "beta-language-server",
          root_markers = { ".git" },
        },
      },
    },
  },
  skipped = {
    lsp = {
      server = "skip_ls",
      mason = "skip-language-server",
      skip_builtin = true,
    },
  },
}

package.loaded["config.lsp.capabilities"] = capabilities
package.loaded["config.lsp.mappings"] = {
  setup = function()
    mappings_were_set = true
  end,
}

vim.lsp.config = function(name, config)
  registrations[name] = config
end

vim.lsp.enable = function(name)
  enabled[name] = true
end

package.loaded["config.lsp"] = nil
require("config.lsp").setup()

assert(mappings_were_set, "LSP mappings were not configured")
assert(registrations["*"], "shared LSP defaults were not registered")
assert(registrations["*"].capabilities == capabilities, "shared capabilities were not inherited")
assert(registrations.alpha_ls, "single-server config was not registered")
assert(
  registrations.alpha_ls.handlers["test/handler"] == handlers["test/handler"],
  "additional LSP fields were not forwarded"
)
assert(registrations.alpha_ls.server == nil, "server metadata leaked into vim.lsp.config")
assert(registrations.alpha_ls.mason == nil, "Mason metadata leaked into vim.lsp.config")
assert(registrations.beta_ls, "multi-server config was not registered")
assert(registrations.beta_ls.root_markers[1] == ".git", "multi-server fields were not forwarded")
assert(enabled.alpha_ls and enabled.beta_ls, "declared servers were not enabled")
assert(not registrations.skip_ls and not enabled.skip_ls, "opt-out server was configured")

vim.cmd("qall!")
