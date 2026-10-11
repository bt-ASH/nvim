-- 快速全项目查找替换
--
-- 绑定：<Leader>A（见 lua/plugins/my_mappings.lua）
-- 用法：按 ,A 弹出输入框，填 "查找/替换"，例如  icons/icons  回车
--       也接受 ">" 作分隔符（icons>icons）。
--
-- 设计要点：
--   * 用 rg 列出候选文件，自动尊重 .gitignore
--   * 逐文件做字节级**字面量**替换，不走 Vim 正则 ——
--     所以查找词里的 / . * ( ) 等特殊字符都当普通字符处理，
--     且不会动行尾符和编码（io 用 "rb"/"wb"）
--   * 替换前弹一次确认并列出受影响文件；替换后重载已打开的 buffer
--   * 这是直接改磁盘文件，不进 Vim 的 undo 栈 —— 动手前请确认已提交 git

local M = {}

---输入框里可用的分隔符：先试 "/"，不成立再退到 ">"
local SEPARATORS = { "/", ">" }

---解析 "查找/替换"
---@param input string
---@return string? find
---@return string? repl
local function parse(input)
  for _, sep in ipairs(SEPARATORS) do
    local find, repl = input:match("^(.-)" .. vim.pesc(sep) .. "(.*)$")
    if find and find ~= "" then
      return find, repl
    end
  end
  return nil, nil
end

---用 rg 列出包含 find 的文件（尊重 .gitignore）
---@param root string
---@param find string
---@return string[]? files
---@return string? err
local function list_files(root, find)
  local res = vim
    .system(
      { "rg", "--files-with-matches", "--fixed-strings", "--no-messages", "--", find },
      { cwd = root, text = true }
    )
    :wait()
  -- rg 的退出码：0=有匹配，1=无匹配，2=出错
  if res.code ~= 0 and res.code ~= 1 then
    return nil, (res.stderr or "rg 执行失败"):gsub("%s+$", "")
  end
  local files = {}
  for line in (res.stdout or ""):gmatch "[^\n]+" do
    files[#files + 1] = line
  end
  return files
end

---在单个文件里做字面量替换
---@param path string
---@param find string
---@param repl string
---@return integer count 替换处数（0 表示未改动）
---@return string? err
local function replace_in_file(path, find, repl)
  local rh = io.open(path, "rb")
  if not rh then
    return 0, "无法读取"
  end
  local data = rh:read "a"
  rh:close()
  if not data then
    return 0, "读取失败"
  end

  local count = 0
  -- 用函数做替换体，避免替换文本里的 % 被当成捕获组引用
  local out = data:gsub(vim.pesc(find), function()
    count = count + 1
    return repl
  end)

  if count > 0 then
    local wh = io.open(path, "wb")
    if not wh then
      return 0, "无法写入"
    end
    wh:write(out)
    wh:close()
  end
  return count
end

---执行替换（不做任何交互，便于测试与复用）
---@param root string 搜索根目录
---@param find string
---@param repl string
---@return integer changed_files
---@return integer total_hits
---@return string[] changed_paths
---@return string? err
function M.replace(root, find, repl)
  local files, err = list_files(root, find)
  if not files then
    return 0, 0, {}, err
  end

  local total, changed = 0, {}
  for _, rel in ipairs(files) do
    local path = root .. "/" .. rel
    local n = replace_in_file(path, find, repl)
    if n > 0 then
      total = total + n
      changed[#changed + 1] = path
    end
  end
  return #changed, total, changed
end

---重载受影响的、已打开且未修改的 buffer
---@param paths string[]
local function reload_buffers(paths)
  for _, path in ipairs(paths) do
    local buf = vim.fn.bufnr(path)
    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd "silent! edit!"
      end)
    end
  end
  vim.cmd "checktime"
end

---解析替换范围：git 根 > 当前文件所在目录 > 当前工作目录
---@return string root
---@return string source 范围的来源说明（用于提示）
local function resolve_root()
  local git_root = vim.fs.root(0, ".git")
  if git_root then
    return git_root, "git 根目录"
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    local dir = vim.fs.dirname(name)
    if dir and dir ~= "" then
      return dir, "当前文件所在目录"
    end
  end
  return vim.fn.getcwd(), "当前工作目录"
end

---范围是否过宽到危险
---
---只拦真正会出事的那一种：$HOME 本身、文件系统根、或 $HOME 的祖先目录。
---2026-10-11 的事故是"静默回退到 CWD 且在 $HOME 下运行"，把整个家目录当成
---项目扫了一遍 —— 问题出在范围，而不是"这个目录没有 git"。
---在非 git 目录里替换是正常用法，不该被拦。
---@param root string
---@return boolean
local function too_broad(root)
  local norm = vim.fs.normalize(root)
  if norm == "/" then
    return true
  end
  local home = vim.fs.normalize(vim.fn.expand "~")
  if norm == home then
    return true
  end
  -- root 是 $HOME 的祖先（例如 /home）
  return home:sub(1, #norm + 1) == norm .. "/"
end

---交互入口：<Leader>A
function M.run()
  vim.ui.input({ prompt = "查找/替换 (例: logo/icons): " }, function(input)
    if not input or input == "" then
      return
    end
    local find, repl = parse(input)
    if not find then
      vim.notify("格式应为 查找/替换，例如 logo/icons", vim.log.levels.WARN)
      return
    end

    -- 范围解析 + 过宽护栏。
    -- 2026-10-11 修正：上一版要求"必须在 git 仓库内"，那是矫枉过正 ——
    -- 真正危险的是范围太宽（$HOME / 根目录），不是"没有 git"。
    local root, source = resolve_root()
    if too_broad(root) then
      vim.notify(
        ("范围过宽（%s: %s），会覆盖整个家目录或磁盘根，已拒绝。\n请在具体的项目或子目录里操作。"):format(
          source,
          root
        ),
        vim.log.levels.ERROR
      )
      return
    end

    local files, err = list_files(root, find)
    if not files then
      vim.notify("rg 出错: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if #files == 0 then
      vim.notify(("没有找到 %q"):format(find), vim.log.levels.INFO)
      return
    end

    -- 文件清单走通知渠道，不要塞进对话框。
    -- 2026-10-11 修正：原先用 vim.fn.confirm() 传多行长消息，在 noice.nvim 下
    -- 会先当作 message 渲染、需要额外按键消掉，再弹真正的对话框 —— 表现为
    -- "弹两次是否"，且按键被消息吃掉导致确认失败、替换不执行。
    -- 现在改成：长清单交给 vim.notify，决策用 vim.ui.select（单行短提示）。
    local listing = table.concat(vim.list_slice(files, 1, 10), "\n")
    if #files > 10 then
      listing = listing .. ("\n… 另有 %d 个"):format(#files - 10)
    end
    vim.notify(
      ("将替换 %d 个文件:\n%s"):format(#files, listing),
      vim.log.levels.INFO,
      { title = "quick_replace: " .. root }
    )

    vim.ui.select({ "替换", "取消" }, {
      prompt = ("%d 个文件: %s → %s"):format(#files, find, repl),
    }, function(choice)
      if choice ~= "替换" then
        return
      end
      local changed_files, total, changed = M.replace(root, find, repl)
      reload_buffers(changed)
      vim.notify(("替换完成: %d 个文件, %d 处"):format(changed_files, total), vim.log.levels.INFO)
    end)
  end)
end

return M
