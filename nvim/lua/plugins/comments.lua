return {
  "numToStr/Comment.nvim",
  version = "*",

  keys = {
    -- NORMAL mode: toggle comment on the current line
    {
      "<leader>/",
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      desc = "Toggle comment (line)",
      mode = "n",
    },

    -- VISUAL mode: toggle comment on the selected block
    {
      "<leader>/",
      function()
        local api = require("Comment.api")
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

        vim.api.nvim_feedkeys(esc, "nx", false)
        api.toggle.linewise(vim.fn.visualmode())
      end,
      desc = "Toggle comment (visual selection)",
      mode = "v",
    },
  },

  config = function()
    require("Comment").setup()
  end,
}
