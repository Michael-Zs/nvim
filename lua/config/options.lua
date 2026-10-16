-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.diffopt = vim.opt.diffopt + { "vertical", "iwhite", "indent-heuristic", "algorithm:patience" }

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "c", "cpp", "h", "hpp" },
--   callback = function()
--     vim.opt_local.foldmethod = "marker"
--     vim.opt_local.foldmarker = "{{{,}}}"
--     vim.opt_local.foldlevel = 99  -- 默认展开所有
--   end,
-- })

-- 保存折叠信息
vim.o.viewoptions = "cursor,folds,slash,unix" -- 保存折叠等视图信息
require("config.folds").setup()

-- 完整 gutter 使用混合行号；分屏时由 config.windows 临时隐藏。
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4

vim.opt.modeline = false

-- vim.g.snacks_animate = false
