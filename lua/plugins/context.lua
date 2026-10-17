return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      -- 跨多行的 context 节点（如 Python 一行一参数的 class/def 签名）
      -- 只显示第一行，避免签名太长时 context 窗口占用过多行数。
      -- 语义：节点行数 <= 该值时整段显示，超过则从尾部裁到只剩第一行。
      multiline_threshold = 1,
    },
  },
}
