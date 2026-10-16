---获取视觉选择的精确文本
---@return string|nil
local function get_visual_selection_text()
  local current_mode = vim.fn.mode()
  if not (current_mode == "v" or current_mode == "V" or current_mode == "\22") then
    return nil
  end

  local anchor = vim.fn.getpos("v") -- [bufnr, lnum, col, off]
  local cursor = vim.api.nvim_win_get_cursor(0) -- [lnum, col] (col is 0-indexed)

  -- 转换为 1-indexed 坐标
  local p1 = { lnum = anchor[2], col = anchor[3] }
  local p2 = { lnum = cursor[1], col = cursor[2] + 1 }

  -- 确定起点和终点（按位置顺序）
  local start_coords, end_coords
  if p1.lnum < p2.lnum or (p1.lnum == p2.lnum and p1.col <= p2.col) then
    start_coords, end_coords = p1, p2
  else
    start_coords, end_coords = p2, p1
  end

  -- 获取行内容
  local lines = vim.api.nvim_buf_get_lines(0, start_coords.lnum - 1, end_coords.lnum, false)
  if #lines == 0 then
    return nil
  end

  -- 根据视觉模式类型处理文本
  if current_mode == "V" then
    -- 行选择：直接拼接所有行
    return table.concat(lines, "\n")
  else
    -- 字符选择 (v) 或块选择 (Ctrl-V)
    if start_coords.lnum == end_coords.lnum then
      -- 单行
      return string.sub(lines[1], start_coords.col, end_coords.col)
    else
      -- 多行
      local text_parts = {}
      -- 第一行：从 start_col 到末尾
      table.insert(text_parts, string.sub(lines[1], start_coords.col))
      -- 中间行：整行
      for i = 2, #lines - 1 do
        table.insert(text_parts, lines[i])
      end
      -- 最后一行：从开头到 end_col
      table.insert(text_parts, string.sub(lines[#lines], 1, end_coords.col))
      return table.concat(text_parts, "\n")
    end
  end
end

function addNote()
  local text = get_visual_selection_text()
  if not text or #text == 0 then
    print("No selection")
    return
  end

  vim.ui.input({ prompt = "notes:", default = "" }, function(input)
    if input == nil then
      print("Input cancelled")
      return
    end

    local filetype = vim.bo.filetype
    local note = "# note: " .. input .. "\n\n```" .. filetype .. "\n" .. text .. "\n```\n\n-----\n\n"
    local file = io.open("/home/zsm/Documents/obsidian/notes/tech/notes.md", "a")
    if file then
      file:write(note)
      file:close()
      print("Note saved")
    end
  end)
end
