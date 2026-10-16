return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load early
    lazy = false, -- Load immediately
    config = function()
      vim.cmd("colorscheme catppuccin")
    end,
  },
}
