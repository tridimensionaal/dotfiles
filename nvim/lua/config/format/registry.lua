local languages = {
  lua = require("config.format.languages.lua"),
}

local formatters_by_ft = {}
local formatter_configs = {}

for ft, lang in pairs(languages) do
  formatters_by_ft[ft] = lang.formatters
  if lang.config then
    for name, cfg in pairs(lang.config) do
      formatter_configs[name] = cfg
    end
  end
end

return {
  formatters_by_ft = formatters_by_ft,
  formatters = formatter_configs,
}
