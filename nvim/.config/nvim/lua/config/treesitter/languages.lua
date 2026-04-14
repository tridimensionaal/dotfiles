local M = {}

local languages = require("config.languages")

-- Core parsers not tied to a single language module.
local core_parsers = {
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "json",
  "ssh_config",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

local function add_unique(acc, seen, parser)
  if type(parser) ~= "string" or seen[parser] then
    return
  end

  table.insert(acc, parser)
  seen[parser] = true
end

function M.parsers()
  local parsers = {}
  local seen = {}

  for _, parser in ipairs(core_parsers) do
    add_unique(parsers, seen, parser)
  end

  for _, lang in pairs(languages) do
    local treesitter = lang.treesitter
    if treesitter and type(treesitter.parsers) == "table" then
      for _, parser in ipairs(treesitter.parsers) do
        add_unique(parsers, seen, parser)
      end
    end
  end

  return parsers
end

function M.start(bufnr)
  local ok_parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok_parser then
    return
  end

  pcall(vim.treesitter.start, bufnr)
end

return M
