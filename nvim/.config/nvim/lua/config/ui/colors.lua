local M = {}

function M.apply()
  local ok, dracula = pcall(require, "dracula")
  if not ok then
    return
  end

  dracula.setup({
    transparent_bg = true,
    show_end_of_buffer = false,
    lualine_bg_color = "none",
    overrides = function(colors)
      return {
        CursorLineNr = { fg = colors.yellow, bg = "NONE" },
        WinSeparator = { fg = colors.comment, bg = "NONE" },
        NormalFloat = { bg = colors.bg },
        FloatBorder = { fg = colors.comment, bg = colors.bg },
        Pmenu = { bg = colors.bg },
        PmenuSel = { fg = colors.fg, bg = colors.selection },
        PmenuSbar = { bg = colors.bg },
        PmenuThumb = { bg = colors.selection },
        IblIndent = { fg = colors.selection, nocombine = true },
        IblScope = { fg = colors.comment, nocombine = true },
      }
    end,
  })

  pcall(vim.cmd.colorscheme, "dracula")
end

return M
