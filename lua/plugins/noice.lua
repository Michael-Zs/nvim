-- <leader>sn 已让给 waymark.nvim 的 picker。
-- 禁用 noice 的 sn* 分组前缀及全部子键，避免 lazy.nvim 启动时覆盖 waymark 的映射，
-- 也避免残留的更长映射（snl/snh/...）让 <leader>sn 按下后进入 which-key 等待。
return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      -- blink.cmp 已开 signature 窗口（见 lua/plugins/blink.lua），
      -- noice 的 auto_open 会在输入 ( 时重复弹一个"编辑即消失"的窗，关掉它；
      -- 手动 gK / <C-k> 仍走 noice 渲染。
      signature = {
        auto_open = {
          enabled = false,
        },
      },
    },
  },
  keys = {
    { "<leader>sn", false },
    { "<leader>snl", false },
    { "<leader>snh", false },
    { "<leader>sna", false },
    { "<leader>snd", false },
    { "<leader>snt", false },
  },
}
