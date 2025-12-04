-- necessary before lazy_init
vim.g.mapleader = " "

-- Load default configurations and plugins
-- it is like automatic require("something")
for _, source in ipairs({
  "lazy_init",
  "mappings",
  "options",
  "autocmds",
}) do
  local ok, fault = pcall(require, source)
  if not ok then
    vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault)
  end
end

-- Load custom configurations
local exist, custom = pcall(require, "custom")
if exist and type(custom) == "table" and custom.configs then
  custom.configs()
end
