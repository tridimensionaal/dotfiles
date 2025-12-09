local registry = require("config.lint.registry")
local lint = require("lint")

lint.linters_by_ft = registry.linters_by_ft

for name, cfg in pairs(registry.linters) do
  lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name] or {}, cfg)
end

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
