-- Matugen generated catppuccin overrides for nvim
local palette = {
  bg = "#261d1f",
  fg = "#efdee1",
  primary = "#ffb1c3",
  secondary = "#e4bdc4",
  tertiary = "#edbe92",
  error = "#ffb4ab",
}

local function hex_highlight(name, bg, fg, opts)
  local cmd = "highlight " .. name
  if bg then cmd = cmd .. " guibg=" .. bg end
  if fg then cmd = cmd .. " guifg=" .. fg end
  if opts then cmd = cmd .. " " .. opts end
  vim.cmd(cmd)
end

-- make catppuccin recolor when changing palette (source this file after matugen)
vim.cmd("colorscheme catppuccin")
hex_highlight("Normal", nil, palette.fg)
hex_highlight("FloatBorder", palette.tertiary, palette.fg, "gui=bold")
hex_highlight("TelescopeBorder", palette.tertiary, nil, "gui=bold")
