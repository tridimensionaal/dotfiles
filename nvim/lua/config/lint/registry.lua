local languages = {
  lua = require("config.lint.languages.lua"),
  python = require("config.lint.languages.python"),
}

local linters_by_ft = {}
local linter_configs = {}

for ft, lang in pairs(languages) do
  linters_by_ft[ft] = lang.linters
  if lang.config then
    for name, cfg in pairs(lang.config) do
      linter_configs[name] = cfg
    end
  end
end

return {
  linters_by_ft = linters_by_ft,
  linters = linter_configs,
}
