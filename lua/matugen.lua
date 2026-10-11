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
    base00 = '#d7e7f4',
    base01 = '#c8deef',
    base02 = '#c0d9ed',
    base03 = '#6d8699',
    base04 = '#4f5458',
    base05 = '#181a1b',
    base06 = '#181a1b',
    base07 = '#181a1b',
    base08 = '#fd4663',
    base09 = '#53288b',
    base0A = '#2932a3',
    base0B = '#227dc3',
    base0C = '#461b7e',
    base0D = '#175482',
    base0E = '#1b227e',
    base0F = '#1f29ad',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#181a1b',          bg = '#d7e7f4' })
  hi('TelescopeBorder',         { fg = '#6d8699',             bg = '#d7e7f4' })
  hi('TelescopePromptNormal',   { fg = '#181a1b',          bg = '#d7e7f4' })
  hi('TelescopePromptBorder',   { fg = '#6d8699',             bg = '#d7e7f4' })
  hi('TelescopePromptPrefix',   { fg = '#227dc3',             bg = '#d7e7f4' })
  hi('TelescopePromptCounter',  { fg = '#4f5458',  bg = '#d7e7f4' })
  hi('TelescopePromptTitle',    { fg = '#d7e7f4',             bg = '#227dc3' })
  hi('TelescopePreviewTitle',   { fg = '#d7e7f4',             bg = '#2932a3' })
  hi('TelescopeResultsTitle',   { fg = '#d7e7f4',             bg = '#53288b' })
  hi('TelescopeSelection',      { fg = '#181a1b',          bg = '#c0d9ed' })
  hi('TelescopeSelectionCaret', { fg = '#227dc3',             bg = '#c0d9ed' })
  hi('TelescopeMatching',       { fg = '#227dc3',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#181a1b',          bg = '#d7e7f4' })
  hi('MiniPickBorder',         { fg = '#6d8699',             bg = '#d7e7f4' })
  hi('MiniPickPrompt',   { fg = '#181a1b',          bg = '#d7e7f4' })
  hi('MiniPickPromptPrefix',   { fg = '#227dc3',             bg = '#d7e7f4' })
  hi('MiniPickBorderText',    { fg = '#d7e7f4',             bg = '#227dc3' })
  hi('MiniPickMatchCurrent',      { fg = '#181a1b',          bg = '#c0d9ed' })
  hi('MiniPickPromptCaret', { fg = '#227dc3',             bg = '#c0d9ed' })
  hi('MiniPickMatchRanges',       { fg = '#227dc3',             bold = true })
end

-- astroui 状态栏/标签栏 buffer 配色。
-- 原先由独立的 ~/.config/matugen（那套已停用）生成到 lua/user/matugen-astroui.lua，
-- 2026-10-11 合并到此处；取值改为 Noctalia 调色板角色，随壁纸明暗自动适配。
-- 消费方: ~/.config/nvim/lua/plugins/astroui.lua 的 status.colors 函数。
M.status = {
  -- 普通/不可见 buffer 的文字
  buffer_fg = '#4f5458',
  -- 当前聚焦 buffer（主题色背景）
  buffer_active_bg = '#227dc3',
  buffer_active_fg = '#0a0a0b',
  -- 可见但未聚焦 buffer（同色系弱化版）
  buffer_visible_bg = '#b2cfe6',
  buffer_visible_fg = '#11293b',
  -- 路径颜色（在主题色背景上仍需可读）
  buffer_path_fg = '#6d8699',
  buffer_active_path_fg = '#b2cfe6',
  buffer_visible_path_fg = '#6d8699',
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
