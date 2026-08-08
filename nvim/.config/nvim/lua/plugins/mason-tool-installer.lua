local function add_tool(ensure, seen, tool)
  if type(tool) ~= "string" or seen[tool] then
    return
  end

  table.insert(ensure, tool)
  seen[tool] = true
end

local function add_lsp_tools(ensure, seen, lsp)
  add_tool(ensure, seen, lsp.mason or lsp.server)

  if type(lsp.servers) ~= "table" then
    return
  end

  for _, config in ipairs(lsp.servers) do
    if type(config) == "string" then
      add_tool(ensure, seen, config)
    elseif type(config) == "table" then
      add_tool(ensure, seen, config.mason or config.server)
    end
  end
end

return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "mason-org/mason.nvim" },

  opts = function()
    local languages = require("config.languages")
    local ensure = {}
    local seen = {}

    for _, lang in pairs(languages) do
      if lang.lsp then
        add_lsp_tools(ensure, seen, lang.lsp)
      end

      if lang.format and lang.format.tools then
        for _, tool in ipairs(lang.format.tools) do
          add_tool(ensure, seen, tool)
        end
      end

      if lang.lint and lang.lint.tools then
        for _, tool in ipairs(lang.lint.tools) do
          add_tool(ensure, seen, tool)
        end
      end
    end

    return {
      ensure_installed = ensure,
      auto_update = false,
      run_on_start = true,
    }
  end,
}
