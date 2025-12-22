local languages = { "lua", "python", "rust", "markdown" }
local M = {}

for _, name in ipairs(languages) do
  local mod = require("config.languages." .. name)
  local ok, plugins = pcall(require, "config.languages." .. name .. ".plugins")

  if ok and type(plugins) == "table" then
    mod.plugins = plugins
  end

  M[name] = mod
end

return M
