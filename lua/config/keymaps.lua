require("config.ob_note")
local split = require("config.split")

-- jf to quit
vim.api.nvim_set_keymap("i", "jf", "<ESC>", { noremap = true })

-- Map J to <C-d> (scroll down), K to <C-u> (scroll up) in normal mode
vim.keymap.set({ "n", "x" }, "J", "<C-d>", { noremap = true, silent = true, desc = "Scroll down half page" })
vim.keymap.set({ "n", "x" }, "K", "<C-u>", { noremap = true, silent = true, desc = "Scroll up half page" })

-- bind - as $ ("v" = visual + select, "o" = operator-pending so d-/y- work)
vim.keymap.set({ "n", "v", "o" }, "-", "$", { noremap = true, silent = true })

vim.keymap.set({ "n", "x" }, "<LocalLeader>r", function()
  pcall(function()
    vim.cmd("AerialClose")
  end)
  vim.cmd("Trouble lsp toggle")
end, { noremap = true, silent = true, desc = "Toggle lsp symbols" })

vim.keymap.set("n", "[c", function()
  -- diff 窗口里回退到内置的"上一个改动"
  -- normal! 的 ! 表示不经过任何映射执行原始按键，既调用内置行为又避免递归触发自己
  if vim.wo.diff then
    return vim.cmd("normal! " .. vim.v.count1 .. "[c")
  end
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Prev Context" })

vim.keymap.set("n", "<leader>tc", function()
  vim.cmd("TSContext toggle")
end, { noremap = true, silent = true, desc = "Toggle TSContext" })

-- Toggle LSP（全局开关）
local lsp_disabled = nil

local function toggle_lsp()
  if lsp_disabled then
    -- 恢复之前禁用的 servers
    vim.lsp.enable(lsp_disabled, true)
    lsp_disabled = nil
    vim.notify("LSP enabled")
  else
    -- 记录当前启用的所有 config，然后全部禁用
    lsp_disabled = vim.tbl_keys(vim.lsp._enabled_configs)
    vim.lsp.enable(lsp_disabled, false) -- 会自动停掉相关 client
    vim.notify("LSP disabled")
  end
end

-- Toggle LSP
vim.keymap.set("n", "<leader>tl", toggle_lsp, { noremap = true, silent = true, desc = "Toggle LSP" })
-- use <leader>ud to toggle lsp diagnostics

-- Toggle snacks.scroll
Snacks.toggle.scroll():map("<leader>ta")

vim.keymap.set("n", "<leader>ts", require("config.windows").toggle_gutter, { desc = "Toggle gutter" })

-- \s for hover
vim.keymap.set("n", "<LocalLeader>s", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Hover" }) -- hover info

vim.keymap.set("n", "<leader>v", function()
  -- Snacks.picker.lsp_symbols() -- can also use lsp symbols
  require("aerial").snacks_picker()
end, { noremap = true, silent = true, desc = "Symbols" })

-- 快捷键切换窗口
vim.keymap.set("n", "`", "<C-w>w", { desc = "切换到下一个窗口" })
-- vim.keymap.set("n", "<S-Tab>", "<C-w>W", { desc = "切换到上一个窗口" })

-- 最大化/恢复当前窗口
Snacks.toggle.zoom():map("<leader>m")

-- 使用zm 来折叠代码, toggle fold
vim.keymap.set("n", "zm", function()
  vim.cmd("normal! za")
end, { noremap = true, silent = true, desc = "Toggle fold" })

-- add note to obsidian
vim.keymap.set("v", "<LocalLeader>n", addNote, { silent = true, desc = "Add to note" })

-- \x: 选择 buffer 右分屏打开，或关闭已有的右侧代码窗口
vim.keymap.set(
  "n",
  "<LocalLeader>x",
  split.search,
  { noremap = true, silent = true, desc = "Toggle right split (select buffer)" }
)

-- \c: 右分屏恢复最近选择的 buffer，或关闭已有的右侧代码窗口
vim.keymap.set(
  "n",
  "<LocalLeader>c",
  split.recent,
  { noremap = true, silent = true, desc = "Toggle right split (recent buffer)" }
)

vim.keymap.set("n", "<Leader>[", function()
  vim.cmd("tabprevious")
end, { noremap = true, silent = true, desc = "Previous tab" })

vim.keymap.set("n", "<Leader>]", function()
  vim.cmd("tabnext")
end, { noremap = true, silent = true, desc = "Next tab" })
