local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("remember_folds", { clear = true })
  local pending = {}
  local lsp_ready = {}

  local function is_file(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
  end

  local function load(win, buf, keep_cursor)
    if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
      return false
    end
    return vim.api.nvim_win_call(win, function()
      local view = keep_cursor and vim.fn.winsaveview() or nil
      -- loadview 会重设 foldexpr；禁止触发 OptionSet，以免清空 LSP 折叠缓存。
      local ok = pcall(vim.cmd, "silent noautocmd loadview")
      if view then
        vim.fn.winrestview(view)
      end
      return ok
    end)
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
      if not is_file(ev.buf) then
        return
      end
      local win = vim.api.nvim_get_current_win()
      local state = { buf = ev.buf, loading = true }
      pending[win] = state
      -- 等 FileType 和其他初始化回调完成后，先恢复同步生成的折叠。
      vim.schedule(function()
        if pending[win] ~= state then
          return
        end
        local ok = load(win, ev.buf, false)
        state.loading = false
        if not ok or lsp_ready[ev.buf] then
          pending[win] = nil
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("LspRequest", {
    group = group,
    callback = function(ev)
      local request = ev.data.request
      if request.method ~= "textDocument/foldingRange" or request.type ~= "complete" then
        return
      end
      -- complete 事件早于响应处理函数；下一轮才有可用于恢复的折叠范围。
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(ev.buf) then
          return
        end
        lsp_ready[ev.buf] = true
        for win, state in pairs(pending) do
          if state.buf == ev.buf and not state.loading then
            pending[win] = nil
            if vim.api.nvim_win_is_valid(win) and vim.wo[win].foldexpr == "v:lua.vim.lsp.foldexpr()" then
              load(win, ev.buf, true)
            end
          end
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = group,
    callback = function(ev)
      if not is_file(ev.buf) then
        return
      end
      local win = vim.api.nvim_get_current_win()
      local state = pending[win]
      -- 尚未恢复时退出，不要用空折叠覆盖磁盘上原有的状态。
      if state and state.loading then
        return
      end
      if vim.wo.foldexpr == "v:lua.vim.lsp.foldexpr()" and not lsp_ready[ev.buf] then
        return
      end
      pcall(vim.cmd, "silent mkview")
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      pending[tonumber(ev.match)] = nil
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(ev)
      lsp_ready[ev.buf] = nil
    end,
  })
end

return M
