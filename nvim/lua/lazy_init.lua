-- bootstrap plugins & lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- path where its going to be installed
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = "plugins",
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
  defaults = {
    lazy = false,
    version = nil,
  },
  ui = {
    icons = {
      ft = "",
      lazy = "󰂠",
      loaded = "",
      not_loaded = "",
    },
  },
  performance = {
    cache = {
      enabled = true,
    },
  },
  state = vim.fn.stdpath("state") .. "/lazy/state.json",
})
