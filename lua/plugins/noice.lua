-- <leader>sn 已让给 waymark.nvim 的 picker。
-- 禁用 noice 的 sn* 分组前缀及全部子键，避免 lazy.nvim 启动时覆盖 waymark 的映射，
-- 也避免残留的更长映射（snl/snh/...）让 <leader>sn 按下后进入 which-key 等待。
return {
  "folke/noice.nvim",
  keys = {
    { "<leader>sn", false },
    { "<leader>snl", false },
    { "<leader>snh", false },
    { "<leader>sna", false },
    { "<leader>snd", false },
    { "<leader>snt", false },
  },
}
