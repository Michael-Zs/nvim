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
vim.o.viewoptions = "folds,slash,unix" -- 光标位置由跳转插件和 LazyVim 的 last_loc 管理
require("config.folds").setup()

-- 完整 gutter 使用混合行号；分屏时由 config.windows 临时隐藏。
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4

vim.opt.modeline = false

-- vim.g.snacks_animate = false

-- 自动加载项目本地配置：执行「启动目录及其所有父目录」中的 .nvim.lua / .nvimrc / .exrc
-- （0.12+ 会向上查找，所以在子目录里启动 nvim 也能加载项目根目录的 .nvim.lua）
-- 只执行已信任的文件：首次遇到提示查看后需 :trust（按内容 hash 记录，改动文件后要重新信任）
vim.o.exrc = true
