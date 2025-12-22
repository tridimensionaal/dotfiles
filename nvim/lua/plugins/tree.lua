return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  cmd = { "NvimTreeToggle", "NvimTreeFocus" },

  keys = {
    -- keymaps that trigger lazy loading:
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree sidebar" },
    { "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh NvimTree" },
  },

  opts = {
    filters = {
      dotfiles = false,
      -- use anchored patterns so names containing "git" (e.g. gitsigns.lua) are not hidden
      custom = { "^\\.git$", "^node_modules$", "^__pycache__$" },
    },

    disable_netrw = true,
    hijack_netrw = true,
    hijack_unnamed_buffer_when_opening = false,
    sync_root_with_cwd = true,

    update_focused_file = {
      enable = true,
      update_root = false,
    },

    view = {
      adaptive_size = false,
      side = "left",
      width = 28,
      preserve_window_proportions = true,
    },

    renderer = {
      root_folder_label = false,
      highlight_git = true,
      highlight_opened_files = "none",

      indent_markers = {
        enable = false,
      },

      icons = {
        webdev_colors = true,
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true, -- show git status columns on files
        },

        glyphs = {
          symlink = "",

          folder = {
            default = "",
            empty = "",
            empty_open = "",
            open = "",
            symlink = "",
            symlink_open = "",
            arrow_open = "",
            arrow_closed = "",
          },

          git = {
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "➜",
            untracked = "",
            deleted = "",
            ignored = "◌",
          },
        },
      },
    },

    git = {
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
    },
  },
}
