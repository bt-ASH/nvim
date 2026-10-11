-- matugen_colors.lua
-- 让 nvim 浮窗跟随 kitty 背景，避免颜色突兀
local M = {}

function M.apply()
  local highlights = {
    NormalFloat = { bg = "NONE" },
    FloatBorder = { bg = "NONE", fg = "NONE" },
    TelescopeNormal = { bg = "NONE" },
    TelescopeBorder = { bg = "NONE", fg = "NONE" },
    TelescopePromptNormal = { bg = "NONE" },
    TelescopePromptBorder = { bg = "NONE", fg = "NONE" },
    TelescopeResultsNormal = { bg = "NONE" },
    TelescopeResultsBorder = { bg = "NONE", fg = "NONE" },
    LazyHover = { bg = "NONE" },
    LazyButton = { bg = "NONE" },
    MasonNormal = { bg = "NONE" },
    MasonBorder = { bg = "NONE", fg = "NONE" },
    WhichKeyFloat = { bg = "NONE" },
    WhichKeyBorder = { bg = "NONE", fg = "NONE" },
    NoiceMini = { bg = "NONE" },
    NotifyBackground = { bg = "NONE" },
    SnacksNormal = { bg = "NONE" },
    SnacksBorder = { bg = "NONE", fg = "NONE" },
  }
  for name, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, opts)
  end
  -- 应用 matugen 动态语法色
  pcall(dofile, vim.fn.stdpath("config").."/lua/matugen-syntax.lua")
end

-- 每次 colorscheme 加载后自动应用
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.defer_fn(M.apply, 50)
  end,
  desc = "Make floating windows transparent for matugen",
})

-- 启动时也执行一次
vim.defer_fn(M.apply, 200)

return M
