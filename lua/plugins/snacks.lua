return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        -- use "pattern -- glob" or "pattern -- -flags xxx" to search
        "<leader>/",
        LazyVim.pick("grep", {
          filter = {
            transform = function(_, filter)
              local pattern, glob = filter.search:match("^(.-)%s+%-%-%s+(.+)$")

              if pattern and glob then
                glob = vim.trim(glob)
                if glob ~= "" and glob:sub(1, 1) ~= "-" then
                  filter.search = pattern .. " -- -g " .. glob
                end
              end
            end,
          },
        }),
        desc = "Grep (Root Dir, glob)",
      },
    },
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
