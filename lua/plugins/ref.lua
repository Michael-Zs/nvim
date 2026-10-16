return {
  "Michael-Zs/ref.nvim",
  config = function()
    require("ref").setup({
      prefix = "@",
      path_style = "relative", -- "filename" | "relative" | "absolute"
      register = "+",
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>ar", "<cmd>Ref<cr>", { desc = "Copy file ref" })
    vim.keymap.set("v", "<leader>ar", function()
      local start = vim.fn.line("v")
      local end_ = vim.fn.line(".")
      if start > end_ then
        start, end_ = end_, start
      end
      require("ref").yank_ref(start, end_)
    end, { desc = "Copy file ref (visual)" })
  end,
}
