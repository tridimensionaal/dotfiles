local M = {}

-- normalize a language LSP config into a flat list of server configs
--
-- supported shapes:
-- 1) { server = "server_name", ... }
-- 2) { servers = { "server_name", { server = "server_name", ... } } }
--
-- each returned item is a table that must include `server`
--- @param lsp table language LSP config table from `config.languages.*`
--- @return table[] configs normalized list of server config tables
--
-- normalize language LSP config into a list so we support:
-- 1) legacy single server: { server = "..." }
-- 2) multiple servers: { servers = { "...", { server = "...", ... } } }
local function lsp_configs(lsp)
  local configs = {}

  if type(lsp.server) == "string" then
    table.insert(configs, lsp)
  end

  if type(lsp.servers) == "table" then
    for _, config in ipairs(lsp.servers) do
      if type(config) == "string" then
        table.insert(configs, { server = config })
      elseif type(config) == "table" then
        table.insert(configs, config)
      end
    end
  end

  return configs
end
--
-- configure and enable all language servers declared in `config.languages`.
--
-- 1) loads shared LSP mappings and capabilities.
-- 2) iterates all language modules.
-- 3) skips languages that opt out via `skip_builtin`.
-- 4) registers each server with `vim.lsp.config`.
-- 5) enables each server with `vim.lsp.enable`.
function M.setup()
  local languages = require("config.languages")
  local mappings = require("config.lsp.mappings")
  local capabilities = require("config.lsp.capabilities")

  mappings.setup()

  for _, lang in pairs(languages) do
    if lang.lsp and not lang.lsp.skip_builtin then
      -- register and enable every server declared by this language module.
      for _, lsp in ipairs(lsp_configs(lang.lsp)) do
        if type(lsp.server) == "string" then
          vim.lsp.config(lsp.server, {
            capabilities = capabilities,
            on_attach = mappings.on_attach,
            settings = lsp.settings,
            filetypes = lsp.filetypes,
            root_markers = lsp.root_markers,
            cmd = lsp.cmd,
            init_options = lsp.init_options,
          })

          vim.lsp.enable(lsp.server)
        end
      end
    end
  end
end

return M
