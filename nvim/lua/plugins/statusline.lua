-- No need to copy this inside `setup()`. Will be used automatically.
return {
    "echasnovski/mini.statusline",
    opts = {

      -- Content of statusline as functions which return statusline string. See
      -- `:h statusline` and code of default contents (used instead of `nil`).
      content = {
        -- Content for active window
        active = nil,
        -- Content for inactive window(s)
        inactive = nil,
      },

      -- Whether to use icons by default
      use_icons = true,
    }
}
