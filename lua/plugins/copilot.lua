return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    {
      "copilotlsp-nvim/copilot-lsp",
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
  },
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<C-l>",
        next = "<C-i>",
        prev = "<C-k>",
        dismiss = "<C-]>",
      },
    },
    panel = {
      enabled = true,
    },
    nes = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept_and_goto = "<leader>ap",
        accept = false,
        dismiss = "<leader>aD",
      },
    },
  },
}
