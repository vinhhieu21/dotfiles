-- Everforest colorscheme (matches Ghostty/tmux/fzf theme)
return {
  {
    "sainnhe/everforest",
    priority = 1000,
    init = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_enable_italic = true
      -- follows :set background=dark/light for dark-hard / light-med variants
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
