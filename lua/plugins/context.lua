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

  -- LazyVim 给 nvim-treesitter-textobjects 配了 buffer-local 的 [c（Prev Class
  -- Start），优先级高于全局映射，会遮蔽上面 treesitter-context 的 [c，这里删掉它。
  -- 注意：opts 必须写成函数才能删除已合并的键，普通 table opts 是 deep-merge，删不掉。
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      local keys = (opts.move or {}).keys or {}
      keys.goto_previous_start = keys.goto_previous_start or {}
      keys.goto_previous_start["[c"] = nil
      -- 想同时释放 ]c（Next Class Start）的话取消下面两行注释
      -- keys.goto_next_start = keys.goto_next_start or {}
      -- keys.goto_next_start["]c"] = nil
    end,
  },
}
