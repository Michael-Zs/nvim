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
}
