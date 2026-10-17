return {
  "saghen/blink.cmp",
  dependencies = { "xzbdmw/colorful-menu.nvim", opts = {} },
  opts = {
    completion = {
      menu = {
        draw = {
          -- We don't need label_description now because label and label_description are already
          -- combined together in label by colorful-menu.nvim.
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
    },
    sources = {
      providers = {
        snippets = {
          opts = {
            -- friendly-snippets 的 package.json 把 global.json 同时注册给 "all" 和
            -- "markdown"/"tex"/"html" 等语言，blink 合并「全局 + ft」时会加载两遍，
            -- 导致 md 里 "time" 这类 snippet 出现两个相同候选。
            -- 这里让 global.json 只保留 "all" 全局这一份。
            filter_snippets = function(ft, file)
              if ft ~= "all" and ft ~= "global" and file:match("global%.json$") then
                return false
              end
              return true
            end,
          },
        },
      },
    },
    keymap = {
      -- C-y to accept, Enter not bound by blink (native newline), C-b/C-f scroll docs
      preset = "default",
      -- C-u/C-d also scroll documentation
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    },
    signature = {
      enabled = true,
    },
  },
}
