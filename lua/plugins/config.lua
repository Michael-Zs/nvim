return {
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "K", "<C-u>" },
          },
        },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      -- vim.cmd([[
      --   function! OpenMarkdownPreview(url)
      --     execute "silent ! vivaldi --new-window " . a:url
      --   endfunction
      -- ]])
      -- vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
    end,
    ft = { "markdown" },
  },
  {
    "stevearc/aerial.nvim",
    event = "LazyFile",
    opts = function()
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      -- HACK: fix lua's weird choice for `Package` for control
      -- structures like if/else/for/etc.
      icons.lua = { Package = icons.Control }

      ---@type table<string, string[]>|false
      local filter_kind = false
      if LazyVim.config.kind_filter then
        filter_kind = assert(vim.deepcopy(LazyVim.config.kind_filter))
        filter_kind._ = filter_kind.default
        filter_kind.default = nil
      end

      local opts = {
        attach_mode = "global",

        backends = { "treesitter", "lsp" },
        -- backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
        -- backends = {
        --   cpp = { "treesitter", "lsp" },
        --   ["_"] = { "lsp", "treesitter", "markdown", "man", "tag" },
        -- },
        show_guides = true,
        -- close_on_exit = true, feel like not working

        layout = {
          resize_to_content = false,
          win_opts = {
            winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
            signcolumn = "yes",
            statuscolumn = " ",
          },
        },
        icons = icons,
        filter_kind = filter_kind,
        -- stylua: ignore
        guides = {
          mid_item   = "├╴",
          last_item  = "└╴",
          nested_top = "│ ",
          whitespace = "  ",
        },

        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      }

      return opts
    end,

    keys = {
      { "<LocalLeader>v", "<cmd>AerialToggle!<cr>", desc = "Aerial (Symbols)" },
    },
  },
}
