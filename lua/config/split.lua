local M = {}
local windows = require("config.windows")
local last_selected_bufnr
local request_id = 0

local function warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

local function selectable(buf)
  return windows.is_edit_buffer(buf) and vim.bo[buf].buflisted
end

-- Zoom 是覆盖在分屏上的浮窗，先退出再操作底层代码窗口。
local function exit_zoom()
  local zen = package.loaded["snacks.zen"]
  if zen and zen.win and zen.win:valid() then
    if vim.api.nvim_win_get_tabpage(zen.win.win) == vim.api.nvim_get_current_tabpage() then
      zen.win:close()
    end
  end
end

-- 单窗口返回打开分屏所需的上下文；两个左右窗口则关闭右侧。
local function prepare()
  request_id = request_id + 1
  exit_zoom()
  local tab = vim.api.nvim_get_current_tabpage()
  local layout = windows.layout(tab)
  windows.refresh(tab)
  if layout and layout[1] == "leaf" then
    return { tab = tab, win = layout[2], layout = layout, request = request_id }
  end
  if layout and layout[1] == "row" and #layout[2] == 2 and layout[2][1][1] == "leaf" and layout[2][2][1] == "leaf" then
    local ok, err = pcall(vim.api.nvim_win_close, layout[2][2][2], false)
    windows.refresh(tab)
    if not ok then
      warn("无法关闭右侧窗口：" .. tostring(err))
    end
    return
  end
  warn("仅支持一个代码窗口或两个左右代码窗口；当前布局未修改")
end

local function open_right(context, buf)
  if
    context.request ~= request_id
    or context.tab ~= vim.api.nvim_get_current_tabpage()
    or not windows.is_edit_window(context.win)
    or not vim.deep_equal(context.layout, windows.layout(context.tab))
  then
    warn("窗口布局已改变，已取消打开分屏")
    return false
  end
  if not selectable(buf) then
    warn("所选 buffer 已关闭或不再是普通编辑 buffer")
    return false
  end

  -- 沿用原来的行为：实际打开分屏时关闭 Aerial，取消选择时不影响侧栏。
  if vim.fn.exists(":AerialClose") == 2 then
    vim.api.nvim_win_call(context.win, function()
      pcall(vim.cmd, "AerialClose")
    end)
  end
  local ok, err = pcall(vim.api.nvim_open_win, buf, true, { win = context.win, split = "right" })
  windows.refresh(context.tab)
  if not ok then
    warn("无法打开右侧分屏：" .. tostring(err))
  end
  return ok
end

-- \x：选择普通、listed buffer；已有两个左右代码窗口时关闭右侧。
function M.search()
  local context = prepare()
  if not context then
    return
  end
  local listed = vim.tbl_filter(selectable, vim.api.nvim_list_bufs())
  vim.ui.select(listed, {
    prompt = "Vsplit buffer",
    format_item = function(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return "[已关闭]"
      end
      local name = vim.api.nvim_buf_get_name(buf)
      name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":p:~")
      return name .. (vim.bo[buf].modified and " [+]" or "")
    end,
  }, function(buf)
    if buf and open_right(context, buf) then
      last_selected_bufnr = buf
    end
  end)
end

-- \c：打开最近选择的 buffer；记录失效时分屏当前代码窗口。
function M.recent()
  local context = prepare()
  if not context then
    return
  end
  local buf = last_selected_bufnr
  if not buf or not selectable(buf) then
    buf = vim.api.nvim_win_get_buf(context.win)
  end
  open_right(context, buf)
end

return M
