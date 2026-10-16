return {
  {
    "folke/snacks.nvim",
    opts = {
      statuscolumn = {
        left = { "sign", "mark" }, -- 诊断等 sign 优先于 mark
        right = { "fold", "git" },
        folds = {
          open = true, -- 显示已展开的折叠箭头
          git_hl = true, -- 折叠图标使用该行的 Git 标记颜色
        },
      },
    },
  },
}
