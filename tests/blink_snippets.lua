-- 验证：blink.cmp snippets 的 global.json 双重注册问题 & filter_snippets 修复的完备性
-- 运行：nvim --headless -u NONE -i NONE -n -c 'luafile <this-file>'
local lazy = vim.fn.stdpath("data") .. "/lazy"
vim.opt.rtp:append(lazy .. "/blink.cmp")
vim.opt.rtp:append(lazy .. "/friendly-snippets")

local registry_mod = require("blink.cmp.sources.snippets.default.registry")

-- 与 lua/plugins/blink.lua 中相同的 filter
local fix = function(ft, file)
  if ft ~= "all" and ft ~= "global" and file:match("global%.json$") then
    return false
  end
  return true
end

local before = registry_mod.new({})
local after = registry_mod.new({ filter_snippets = fix })

-- 模拟 blink snippets source 的合并逻辑：
-- global_snippets = { "all" }（默认）+ get_snippets_for_ft(ft)，extended_filetypes 默认空
local function merged_files(reg, ft)
  local files = {}
  for _, f in ipairs(reg.registry["all"] or {}) do
    files[#files + 1] = f
  end
  for _, f in ipairs(reg.registry[ft] or {}) do
    files[#files + 1] = f
  end
  return files
end

local function duplicate_files(list)
  local seen, dups = {}, {}
  for _, f in ipairs(list) do
    if seen[f] then
      dups[vim.fs.basename(f)] = true
    else
      seen[f] = true
    end
  end
  local out = vim.tbl_keys(dups)
  table.sort(out)
  return out
end

-- "all"/"global" 是 friendly-snippets 的约定伪键（全局桶的别名），不是真实
-- filetype，blink 只会把它们当 global_snippets 取一次，不会作为 ft 路径再取。
local keys = vim.tbl_keys(before.registry)
keys = vim.tbl_filter(function(k)
  return k ~= "all" and k ~= "global"
end, keys)
table.sort(keys)

local fails = 0
local function expect(cond, msg)
  if cond then
    print("  PASS  " .. msg)
  else
    fails = fails + 1
    print("  FAIL  " .. msg)
  end
end

print(("== 检查 %d 个语言键 =="):format(#keys))

-- ① 修复前：哪些语言会重复加载同一文件（确认 bug 范围）
local dup_langs = {}
for _, ft in ipairs(keys) do
  local d = duplicate_files(merged_files(before, ft))
  if #d > 0 then
    dup_langs[#dup_langs + 1] = ("%s (重复: %s)"):format(ft, table.concat(d, ", "))
  end
end
print("① 修复前存在重复加载的语言数: " .. #dup_langs)
for _, l in ipairs(dup_langs) do
  print("     - " .. l)
end
expect(#dup_langs > 0, "修复前确实存在重复加载（bug 可复现）")

-- ② 修复后：任何语言不得再有重复加载
local dup_after = {}
for _, ft in ipairs(keys) do
  local d = duplicate_files(merged_files(after, ft))
  if #d > 0 then
    dup_after[#dup_after + 1] = ("%s (重复: %s)"):format(ft, table.concat(d, ", "))
  end
end
print("② 修复后仍存在重复加载的语言数: " .. #dup_after)
for _, l in ipairs(dup_after) do
  print("     - " .. l)
end
expect(#dup_after == 0, "修复后所有语言键均无重复加载")

-- ③ 误杀检查：修复后每个语言可用的 snippet 文件集合与修复前（去重后）完全一致
local lost = {}
for _, ft in ipairs(keys) do
  local setb, seta = {}, {}
  for _, f in ipairs(merged_files(before, ft)) do
    setb[f] = true
  end
  for _, f in ipairs(merged_files(after, ft)) do
    seta[f] = true
  end
  for f in pairs(setb) do
    if not seta[f] then
      lost[#lost + 1] = ("%s 丢失 %s"):format(ft, vim.fs.basename(f))
    end
  end
end
print("③ 被误杀（丢失文件）的语言数: " .. #lost)
for _, l in ipairs(lost) do
  print("     - " .. l)
end
expect(#lost == 0, "修复没有让任何语言丢失 snippet 文件")

-- ④ spot check：条目前缀计数（markdown/c/tex 里 time 系 snippet 各只有一份）
for _, ft in ipairs({ "markdown", "c", "tex" }) do
  local merged = vim.list_extend({}, after:get_global_snippets())
  vim.list_extend(merged, after:get_snippets_for_ft(ft))
  local n = 0
  for _, s in ipairs(merged) do
    if s.prefix == "time" then
      n = n + 1
    end
  end
  expect(n == 1, ("%s 中 prefix=='time' 的条目数 == 1（实际 %d）"):format(ft, n))
end

print(fails == 0 and "== ALL PASS ==" or ("== %d FAILED =="):format(fails))
vim.cmd("cq " .. fails)
