return {
  "Michael-Zs/waymark.nvim",
  lazy = false,
  -- keymap 全部集中在插件 setup() 内（见 waymark.nvim/lua/waymark/init.lua）
  config = function()
    require("waymark").setup({})
  end,
}
