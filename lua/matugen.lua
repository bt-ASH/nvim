-- Nyxuri / Noctalia nvim 配色模板
-- 输出: ~/.config/nvim/lua/matugen.lua
-- 注册: ~/.config/noctalia/noctalia-config.toml -> [theme.templates.user.nvim]
--
-- 历史: 2026-10-11 之前这里的基线来自 Noctalia 社区模板 "neovim"（nvim-base16），
-- 并把 ~/.config/nvim/lua/user/matugen-astroui.lua 的 astroui buffer 配色
-- 合并进本文件（M.status），从而收敛为单一配色文件。
-- 社区模板那份由 Noctalia 缓存管理、hash 校验，手改会被覆盖，故改走 user 模板。
local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#fff8f8',
    base01 = '#faeaef',
    base02 = '#f4e4e9',
    base03 = '#85727a',
    base04 = '#524249',
    base05 = '#21191d',
    base06 = '#21191d',
    base07 = '#21191d',
    base08 = '#ba1a1a',
    base09 = '#9d4324',
    base0A = '#7c5267',
    base0B = '#963f71',
    base0C = '#ffb59e',
    base0D = '#ffafd6',
    base0E = '#edb8d0',
    base0F = '#ffd8e8',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#21191d',          bg = '#fff8f8' })
  hi('TelescopeBorder',         { fg = '#85727a',             bg = '#fff8f8' })
  hi('TelescopePromptNormal',   { fg = '#21191d',          bg = '#fff8f8' })
  hi('TelescopePromptBorder',   { fg = '#85727a',             bg = '#fff8f8' })
  hi('TelescopePromptPrefix',   { fg = '#963f71',             bg = '#fff8f8' })
  hi('TelescopePromptCounter',  { fg = '#524249',  bg = '#fff8f8' })
  hi('TelescopePromptTitle',    { fg = '#fff8f8',             bg = '#963f71' })
  hi('TelescopePreviewTitle',   { fg = '#fff8f8',             bg = '#7c5267' })
  hi('TelescopeResultsTitle',   { fg = '#fff8f8',             bg = '#9d4324' })
  hi('TelescopeSelection',      { fg = '#21191d',          bg = '#f4e4e9' })
  hi('TelescopeSelectionCaret', { fg = '#963f71',             bg = '#f4e4e9' })
  hi('TelescopeMatching',       { fg = '#963f71',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#21191d',          bg = '#fff8f8' })
  hi('MiniPickBorder',         { fg = '#85727a',             bg = '#fff8f8' })
  hi('MiniPickPrompt',   { fg = '#21191d',          bg = '#fff8f8' })
  hi('MiniPickPromptPrefix',   { fg = '#963f71',             bg = '#fff8f8' })
  hi('MiniPickBorderText',    { fg = '#fff8f8',             bg = '#963f71' })
  hi('MiniPickMatchCurrent',      { fg = '#21191d',          bg = '#f4e4e9' })
  hi('MiniPickPromptCaret', { fg = '#963f71',             bg = '#f4e4e9' })
  hi('MiniPickMatchRanges',       { fg = '#963f71',             bold = true })
end

-- astroui 状态栏/标签栏 buffer 配色。
-- 原先由独立的 ~/.config/matugen（那套已停用）生成到 lua/user/matugen-astroui.lua，
-- 2026-10-11 合并到此处；取值改为 Noctalia 调色板角色，随壁纸明暗自动适配。
-- 消费方: ~/.config/nvim/lua/plugins/astroui.lua 的 status.colors 函数。
M.status = {
  -- 普通/不可见 buffer 的文字
  buffer_fg = '#524249',
  -- 当前聚焦 buffer（主题色背景）
  buffer_active_bg = '#963f71',
  buffer_active_fg = '#ffffff',
  -- 可见但未聚焦 buffer（同色系弱化版）
  buffer_visible_bg = '#d674a9',
  buffer_visible_fg = '#58083d',
  -- 路径颜色（在主题色背景上仍需可读）
  buffer_path_fg = '#85727a',
  buffer_active_path_fg = '#d674a9',
  buffer_visible_path_fg = '#85727a',
}

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
