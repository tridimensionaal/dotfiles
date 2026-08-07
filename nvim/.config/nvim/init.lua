-- necessary before lazy_init
vim.g.mapleader = " "

-- Load default configurations and plugins
-- it is like automatic require("something")
--
for _, source in ipairs({
  "lazy_init",
  "mappings",
  "options",
  "autocmds",
}) do
  local ok, fault = pcall(require, source)
  if not ok then
    vim.api.nvim_echo({ { "Failed to load " .. source .. "\n\n" .. fault, "ErrorMsg" } }, true, { err = true })
  end
end

-- Load custom configurations
local exist, custom = pcall(require, "custom")
if exist and type(custom) == "table" and custom.configs then
  custom.configs()
end
