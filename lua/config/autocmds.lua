-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local windows = require("config.windows")
local group = vim.api.nvim_create_augroup("CustomSidebar", { clear = true })

-- 保留原来的命令名；这里控制的是代码左侧的 gutter。
vim.api.nvim_create_user_command("SidebarShow", function()
  windows.set_gutter(true)
end, {})
vim.api.nvim_create_user_command("SidebarHide", function()
  windows.set_gutter(false)
end, {})
vim.api.nvim_create_user_command("SidebarToggle", windows.toggle_gutter, {})

vim.api.nvim_create_autocmd({
  "WinNew",
  "WinEnter",
  "WinClosed",
  "WinResized",
  "BufWinEnter",
  "BufEnter",
  "FileType",
  "TabEnter",
  "TabClosed",
  "VimResized",
}, {
  group = group,
  callback = windows.schedule_refresh,
})

vim.api.nvim_create_autocmd("OptionSet", {
  group = group,
  pattern = "buftype",
  callback = windows.schedule_refresh,
})

windows.schedule_refresh()
