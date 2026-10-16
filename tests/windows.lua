-- 运行：nvim --headless -u NONE -i NONE -n -c 'luafile tests/windows.lua'
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
-- 精简 gutter 复用已安装的 Snacks，加载其真实实现以覆盖重绘路径。
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/snacks.nvim")
require("snacks").config.statuscolumn = dofile(root .. "/lua/plugins/snacks.lua")[1].opts.statuscolumn
require("snacks.statuscolumn").setup()
vim.o.hidden = true
vim.o.confirm = false
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.lines = 40
vim.o.columns = 140
vim.opt.statuscolumn = "%s%C"
vim.opt.number = true
vim.opt.relativenumber = true
local defaults = {
  signcolumn = vim.go.signcolumn,
  foldcolumn = vim.go.foldcolumn,
  statuscolumn = vim.go.statuscolumn,
  number = vim.go.number,
  relativenumber = vim.go.relativenumber,
}

local windows = require("config.windows")
require("config.autocmds")
local split = require("config.split")
local notices = {}
local choice, choices
vim.notify = function(message)
  notices[#notices + 1] = message
end
vim.ui.select = function(items, _, callback)
  choices, choice = items, callback
end
vim.api.nvim_create_user_command("AerialClose", function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "aerial" then
      vim.api.nvim_win_close(win, false)
    end
  end
end, {})

local function eq(actual, expected)
  assert(vim.deep_equal(actual, expected), "expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function flush()
  local done = false
  vim.schedule(function()
    done = true
  end)
  assert(
    vim.wait(1000, function()
      return done
    end, 5),
    "scheduled refresh did not complete"
  )
end

local function buffer(ft, bt)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.bo[buf].filetype = ft or "lua"
  vim.bo[buf].buftype = bt or ""
  return buf
end

local function gutter(visible)
  local compact = not visible and #windows.list() > 1
  for _, win in ipairs(windows.list()) do
    eq(vim.wo[win].signcolumn, (visible or compact) and "yes:1" or "no")
    eq(vim.wo[win].foldcolumn, visible and "1" or "0")
    if compact then
      assert(vim.wo[win].statuscolumn:find("right_statuscolumn", 1, true), "missing compact gutter")
      eq(vim.wo[win].number, false)
      eq(vim.wo[win].relativenumber, false)
    else
      eq(vim.wo[win].statuscolumn, visible and defaults.statuscolumn or "")
      eq(vim.wo[win].number, true)
      eq(vim.wo[win].relativenumber, true)
    end
  end
end

local function reset()
  vim.cmd("silent! tabonly!")
  vim.cmd("silent! only!")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.bo[buf].buflisted = false
  end
  vim.api.nvim_win_set_buf(0, buffer())
  split = dofile(root .. "/lua/config/split.lua")
  windows.set_gutter(true)
  notices, choices, choice = {}, nil, nil
  flush()
end

local tests = {}
local function test(name, fn)
  tests[#tests + 1] = { name, fn }
end

test("选择、关闭和恢复最近 buffer；未保存内容保留", function()
  local target = buffer()
  split.search()
  choice(target)
  eq(vim.api.nvim_get_current_buf(), target)
  eq(#windows.list(), 2)
  gutter(false)
  vim.api.nvim_buf_set_lines(target, 0, -1, false, { "unsaved" })
  split.recent()
  eq(#windows.list(), 1)
  gutter(true)
  eq(vim.bo[target].modified, true)
  split.recent()
  eq(vim.api.nvim_get_current_buf(), target)
  eq(vim.api.nvim_buf_get_lines(target, 0, -1, false), { "unsaved" })
end)

test("连续开关后 gutter 恢复且全局默认不变", function()
  for _ = 1, 30 do
    split.recent()
    split.recent()
  end
  flush()
  eq(#windows.list(), 1)
  gutter(true)
  for name, value in pairs(defaults) do
    eq(vim.go[name], value)
  end
end)

test("手动 gutter 覆盖保留到代码窗口布局变化", function()
  windows.set_gutter(false)
  vim.api.nvim_win_set_buf(0, buffer())
  flush()
  gutter(false)
  split.recent()
  windows.set_gutter(true)
  flush()
  gutter(true)
  vim.cmd("wincmd K")
  -- 无 UI 的同步测试不会自然经历触发 WinResized 所需的主循环重绘。
  vim.api.nvim_exec_autocmds("WinResized", {})
  flush()
  gutter(false)
end)

test("每个 tab 的手动状态独立", function()
  local first = vim.api.nvim_get_current_tabpage()
  windows.set_gutter(false)
  vim.cmd("tabnew")
  local second = vim.api.nvim_get_current_tabpage()
  flush()
  gutter(true)
  vim.api.nvim_set_current_tabpage(first)
  flush()
  gutter(false)
  vim.cmd("SidebarToggle")
  gutter(true)
  vim.api.nvim_set_current_tabpage(second)
  flush()
  gutter(true)
end)

test("同 buffer 的其他 tab 保持完整行号，新增分屏能恢复行号", function()
  local first = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()
  split.recent()
  gutter(false)
  local third = vim.api.nvim_open_win(buf, true, { split = "right" })
  flush()
  gutter(false)
  vim.cmd("only")
  flush()
  eq(vim.api.nvim_get_current_win(), third)
  gutter(true)
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
  local second = vim.api.nvim_get_current_tabpage()
  flush()
  gutter(true)
  vim.api.nvim_set_current_tabpage(first)
  split.recent()
  gutter(false)
  vim.cmd("tab split")
  flush()
  gutter(true)
  vim.api.nvim_set_current_tabpage(second)
  flush()
  gutter(true)
end)

for _, side in ipairs({ "left", "right" }) do
  test("Aerial 在" .. side .. "侧仍可选择 buffer，取消不关闭侧栏", function()
    local source = vim.api.nvim_get_current_win()
    local aerial = vim.api.nvim_open_win(buffer("aerial", "nofile"), false, { win = source, split = side })
    flush()
    local target = buffer()
    split.search()
    assert(choice, "picker missing")
    choice(nil)
    assert(vim.api.nvim_win_is_valid(aerial), "cancel closed Aerial")
    split.search()
    choice(target)
    assert(not vim.api.nvim_win_is_valid(aerial), "Aerial not closed")
    assert(vim.api.nvim_win_is_valid(source), "source window closed")
    eq(#windows.list(), 2)
    eq(vim.api.nvim_get_current_buf(), target)
  end)
end

test("Trouble、quickfix、help、终端和浮窗不参与计数或选择", function()
  local source = vim.api.nvim_get_current_win()
  local excluded = { buffer("trouble", "nofile"), buffer("qf", "quickfix"), buffer("help", "help") }
  local terminal = buffer()
  vim.api.nvim_open_term(terminal, {})
  excluded[#excluded + 1] = terminal
  local trouble = vim.api.nvim_open_win(excluded[1], false, { win = source, split = "right" })
  vim.api.nvim_set_option_value("statuscolumn", " ", { win = trouble, scope = "local" })
  local float = vim.api.nvim_open_win(buffer(), false, {
    relative = "editor",
    row = 1,
    col = 1,
    width = 10,
    height = 3,
  })
  flush()
  eq(#windows.list(), 1)
  gutter(true)
  eq(vim.wo[trouble].statuscolumn, " ")
  split.search()
  for _, buf in ipairs(excluded) do
    assert(not vim.tbl_contains(choices, buf), "special buffer offered in picker")
  end
  choice(nil)
  vim.api.nvim_win_close(float, false)
  split.recent()
  split.recent()
  assert(vim.api.nvim_win_is_valid(source))
  assert(vim.api.nvim_win_is_valid(trouble))
  eq(#windows.list(), 1)
end)

test("上下分屏和三个代码窗口不关闭任何窗口", function()
  vim.cmd("split")
  local before = windows.layout()
  split.recent()
  eq(windows.layout(), before)
  vim.cmd("vsplit")
  before = windows.layout()
  split.search()
  eq(windows.layout(), before)
  eq(#notices, 2)
end)

test("不受 splitright 选项影响，始终右分屏", function()
  vim.o.splitright = false
  local source = vim.api.nvim_get_current_win()
  split.recent()
  local layout = windows.layout()
  eq(layout[1], "row")
  eq(layout[2][1][2], source)
  eq(layout[2][2][2], vim.api.nvim_get_current_win())
  vim.o.splitright = true
end)

test("等待选择期间布局变化，不关闭已有窗口", function()
  split.search()
  vim.cmd("vsplit")
  local before = windows.layout()
  choice(vim.api.nvim_get_current_buf())
  eq(windows.layout(), before)
  eq(#notices, 1)
end)

test("等待选择期间切换 tab，不在其他 tab 打开分屏", function()
  split.search()
  local target = vim.api.nvim_get_current_buf()
  vim.cmd("tabnew")
  choice(target)
  eq(#windows.list(), 1)
  eq(#notices, 1)
end)

test("失效的选择与关闭的来源窗口不会创建多余分屏", function()
  local target = buffer()
  split.search()
  vim.api.nvim_buf_delete(target, { force = true })
  choice(target)
  eq(#windows.list(), 1)
  eq(#notices, 1)
  split.search()
  local source = vim.api.nvim_get_current_win()
  local replacement = vim.api.nvim_open_win(buffer(), true, { split = "right" })
  vim.api.nvim_win_close(source, false)
  choice(vim.api.nvim_win_get_buf(replacement))
  eq(#windows.list(), 1)
  eq(#notices, 2)
end)

test("新的操作使旧选择回调失效", function()
  local target = buffer()
  split.search()
  local old_choice = choice
  split.recent()
  split.recent()
  old_choice(target)
  eq(#windows.list(), 1)
  eq(#notices, 1)
end)

test("最近 buffer 被删除时退回当前 buffer", function()
  local source = vim.api.nvim_get_current_buf()
  local target = buffer()
  split.search()
  choice(target)
  split.recent()
  vim.api.nvim_buf_delete(target, { force = true })
  split.recent()
  eq(vim.api.nvim_get_current_buf(), source)
end)

test("关闭右侧窗口失败时保留布局和修改", function()
  local target = buffer()
  split.search()
  choice(target)
  vim.api.nvim_buf_set_lines(target, 0, -1, false, { "unsaved" })
  vim.o.hidden = false
  local before = windows.layout()
  split.recent()
  eq(windows.layout(), before)
  eq(vim.bo[target].modified, true)
  eq(#notices, 1)
  vim.o.hidden = true
end)

test("事件合并不遗留 timer", function()
  local function timers()
    local count = 0
    vim.uv.walk(function(handle)
      if handle:get_type() == "timer" and not handle:is_closing() then
        count = count + 1
      end
    end)
    return count
  end
  local before = timers()
  for _ = 1, 100 do
    windows.schedule_refresh()
  end
  flush()
  eq(timers(), before)
end)

vim.schedule(function()
  local failures = 0
  for _, case in ipairs(tests) do
    local ok, err = xpcall(function()
      reset()
      case[2]()
    end, debug.traceback)
    io.stdout:write((ok and "PASS " or "FAIL ") .. case[1] .. "\n")
    if not ok then
      failures = failures + 1
      io.stderr:write(err .. "\n")
    end
  end
  io.stdout:write(("%d/%d passed\n"):format(#tests - failures, #tests))
  vim.cmd(failures == 0 and "qa!" or "cquit")
end)
