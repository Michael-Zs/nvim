return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  },
}
