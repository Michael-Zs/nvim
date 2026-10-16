local M = {}

local ignored_filetypes = {
  aerial = true,
  fugitive = true,
  help = true,
  ["neo-tree"] = true,
  NvimTree = true,
  trouble = true,
}
local tabs = {}
local pending = false
local compact_numbers = {}
local compact_statuscolumn = "%!v:lua.require'config.windows'.right_statuscolumn()"

-- 复用 Snacks 的标记查询与折叠点击处理，仅渲染其右侧组件。
function M.right_statuscolumn()
  if vim.v.virtnum ~= 0 then
    return "  "
  end
  local win = vim.g.statusline_winid
  local status = require("snacks.statuscolumn")
  status.setup()
  -- Snacks 的 sign cache 按 buffer 共用，查询完整集合，避免影响同 buffer 的完整 gutter。
  local signs = status.line_signs(win, vim.api.nvim_win_get_buf(win), vim.v.lnum, {
    sign = true,
    mark = true,
    fold = true,
    git = true,
  })
  local fold, git
  for _, sign in ipairs(signs) do
    if sign.type == "fold" and not fold then
      fold = sign
    elseif sign.type == "git" and not git then
      git = sign
    end
  end
  local sign = fold or git
  if fold and git then
    sign = vim.tbl_extend("force", fold, { texthl = git.texthl })
  end
  return "%@v:lua.require'snacks.statuscolumn'.click_fold@" .. status.icon(sign) .. "%T"
end

function M.is_edit_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and not ignored_filetypes[vim.bo[buf].filetype]
end

function M.is_edit_window(win)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local config = vim.api.nvim_win_get_config(win)
  return config.relative == "" and not config.external and M.is_edit_buffer(vim.api.nvim_win_get_buf(win))
end

-- 保留代码窗口的布局结构，移除侧栏并折叠只有一个子节点的分支。
function M.layout(tab)
  local function filter(node)
    if node[1] == "leaf" then
      return M.is_edit_window(node[2]) and node or nil
    end
    local children = {}
    for _, child in ipairs(node[2]) do
      local filtered = filter(child)
      if filtered then
        children[#children + 1] = filtered
      end
    end
    if #children == 1 then
      return children[1]
    elseif #children > 1 then
      return { node[1], children }
    end
  end
  tab = tab or vim.api.nvim_get_current_tabpage()
  return filter(vim.fn.winlayout(vim.api.nvim_tabpage_get_number(tab)))
end

function M.list(tab)
  return vim.tbl_filter(M.is_edit_window, vim.api.nvim_tabpage_list_wins(tab or 0))
end

function M.refresh(tab)
  tab = tab or vim.api.nvim_get_current_tabpage()
  if not vim.api.nvim_tabpage_is_valid(tab) then
    tabs[tab] = nil
    return
  end

  local layout = M.layout(tab)
  local state = tabs[tab]
  if not state or not vim.deep_equal(state.layout, layout) then
    state = { layout = layout }
    tabs[tab] = state
  end

  local wins = M.list(tab)
  local full = state.manual
  if full == nil then
    full = #wins == 1
  end
  local compact = not full and #wins > 1
  local values = {
    signcolumn = (full or compact) and "yes:1" or "no",
    foldcolumn = full and "1" or "0",
    statuscolumn = full and vim.go.statuscolumn or (compact and compact_statuscolumn or ""),
  }
  local changed = false
  for _, win in ipairs(wins) do
    local dirty = false
    if not compact_numbers[win] and (compact or vim.wo[win].statuscolumn == compact_statuscolumn) then
      -- 新分屏可能继承了精简模式的 nonumber；此时使用全局行号偏好。
      local opts = vim.wo[win].statuscolumn == compact_statuscolumn and vim.go or vim.wo[win]
      compact_numbers[win] = { number = opts.number, relativenumber = opts.relativenumber }
    end
    if compact_numbers[win] then
      for name, value in pairs(compact_numbers[win]) do
        local target = not compact and value
        if vim.wo[win][name] ~= target then
          vim.api.nvim_set_option_value(name, target, { win = win, scope = "local" })
          dirty = true
        end
      end
      if not compact then
        compact_numbers[win] = nil
      end
    end
    for _, name in ipairs({ "signcolumn", "foldcolumn", "statuscolumn" }) do
      -- 列宽变化时也重设 statuscolumn，让其缓存失效。
      if vim.wo[win][name] ~= values[name] or (name == "statuscolumn" and dirty) then
        vim.api.nvim_set_option_value(name, values[name], { win = win, scope = "local" })
        dirty = true
      end
    end
    changed = changed or dirty
  end
  if changed and tab == vim.api.nvim_get_current_tabpage() then
    vim.cmd("redraw!")
  end
  return full
end

-- 合并同一轮事件；无需创建或取消 timer。处理所有 tab，避免切换期间漏更新。
function M.schedule_refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    for win in pairs(compact_numbers) do
      if not vim.api.nvim_win_is_valid(win) then
        compact_numbers[win] = nil
      end
    end
    for tab in pairs(tabs) do
      if not vim.api.nvim_tabpage_is_valid(tab) then
        tabs[tab] = nil
      end
    end
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      M.refresh(tab)
    end
  end)
end

-- 手动覆盖仅作用于当前 tab，代码窗口布局变化后恢复自动规则。
function M.set_gutter(visible)
  local tab = vim.api.nvim_get_current_tabpage()
  M.refresh(tab)
  tabs[tab].manual = visible
  M.refresh(tab)
end

function M.toggle_gutter()
  M.set_gutter(not M.refresh())
end

return M
