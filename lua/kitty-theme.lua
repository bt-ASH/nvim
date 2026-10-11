local M = {}

local kitty_conf = vim.fn.expand("~/.config/kitty/current-theme.conf")

local defaults = {
  foreground         = "#f1dfd9",
  -- background         = "#1a110f",
  cursor             = "#e7bdb0",
  cursor_text_color  = "#d8c2bb",
  selection_foreground = "#442a21",
  selection_background = "#e7bdb0",
  color0             = "#4c4c4c",
  color8             = "#a08d86",
  color1             = "#ac8a8c",
  color9             = "#c49ea0",
  color2             = "#9ab38d",
  color10            = "#b0c9a3",
  color3             = "#aca98a",
  color11            = "#c4c19e",
  color4             = "#ffb59b",
  color12            = "#a39ec4",
  color5             = "#d5c68e",
  color13            = "#f2e2a7",
  color6             = "#e7bdb0",
  color14            = "#e7bdb0",
  color7             = "#f0f0f0",
  color15            = "#e7e7e7",
}

local function parse_kitty_conf(path)
  local file = io.open(path, "r")
  if not file then return {} end
  local result = {}
  for line in file:lines() do
    if not line:match("^%s*#") then
      local key, value = line:match("^%s*(%S+)%s+(%S+)")
      if key and value and value:match("^#[0-9a-fA-F]+") then
        result[key] = value
      end
    end
  end
  file:close()
  return result
end

local function lighten(hex, factor)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  r = math.floor(r + (255 - r) * factor)
  g = math.floor(g + (255 - g) * factor)
  b = math.floor(b + (255 - b) * factor)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function hl(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

function M.apply()
  local kitty = parse_kitty_conf(kitty_conf)

  local function get(key) return kitty[key] or defaults[key] end

  local c = {
    -- bg            = get("background"),
    fg            = get("foreground"),
    cursor        = get("cursor"),
    cursor_text   = get("cursor_text_color"),
    sel_fg        = get("selection_foreground"),
    sel_bg        = get("selection_background"),
    black         = get("color0"),
    bright_black  = get("color8"),
    red           = get("color1"),
    bright_red    = get("color9"),
    green         = get("color2"),
    bright_green  = get("color10"),
    yellow        = get("color3"),
    bright_yellow = get("color11"),
    blue          = get("color4"),
    bright_blue   = get("color12"),
    magenta       = get("color5"),
    bright_magenta= get("color13"),
    cyan          = get("color6"),
    bright_cyan   = get("color14"),
    white         = get("color7"),
    bright_white  = get("color15"),
    cursorline_bg = kitty.cursorline_bg or lighten(get("background"), 0.08),
    linenr        = kitty.linenr or get("color8"),
    nontext       = kitty.nontext or lighten(get("background"), 0.15),
  }

  -- Editor
  hl("Normal",        { fg = c.fg, bg = c.bg })
  hl("NormalFloat",   { fg = c.fg, bg = "NONE" })
  hl("FloatBorder",   { fg = c.fg, bg = "NONE" })
  hl("Cursor",        { fg = c.cursor_text, bg = c.cursor })
  hl("CursorLine",    { bg = c.cursorline_bg })
  hl("CursorLineNr",  { fg = c.fg })
  hl("CursorColumn",  { bg = c.cursorline_bg })
  hl("LineNr",        { fg = c.linenr })
  hl("NonText",       { fg = c.nontext })
  hl("Whitespace",    { fg = c.nontext })
  hl("EndOfBuffer",   { fg = c.bg })
  hl("Visual",        { fg = c.sel_fg, bg = c.sel_bg })
  hl("VisualNOS",     { fg = c.sel_fg, bg = c.sel_bg })
  hl("Search",        { fg = c.sel_fg, bg = c.sel_bg })
  hl("IncSearch",     { fg = c.bg, bg = c.blue })
  hl("CurSearch",     { fg = c.bg, bg = c.blue })
  hl("MatchParen",    { fg = c.blue, bold = true })
  hl("Conceal",       { fg = c.bright_black })
  hl("ColorColumn",   { bg = c.cursorline_bg })

  -- Syntax legacy
  hl("Comment",       { fg = c.bright_black, italic = true })
  hl("Constant",      { fg = c.bright_red })
  hl("String",        { fg = c.green })
  hl("Character",     { fg = c.green })
  hl("Number",        { fg = c.bright_red })
  hl("Boolean",       { fg = c.bright_green })
  hl("Float",         { fg = c.bright_red })
  hl("Identifier",    { fg = c.fg })
  hl("Function",      { fg = c.blue })
  hl("Statement",     { fg = c.magenta })
  hl("Conditional",   { fg = c.magenta })
  hl("Repeat",        { fg = c.magenta })
  hl("Label",         { fg = c.magenta })
  hl("Operator",      { fg = c.white })
  hl("Keyword",       { fg = c.magenta })
  hl("Exception",     { fg = c.magenta })
  hl("Type",          { fg = c.yellow })
  hl("StorageClass",  { fg = c.magenta })
  hl("Structure",     { fg = c.magenta })
  hl("Typedef",       { fg = c.yellow })
  hl("PreProc",       { fg = c.blue })
  hl("Include",       { fg = c.blue })
  hl("Define",        { fg = c.blue })
  hl("Macro",         { fg = c.bright_magenta })
  hl("PreCondit",     { fg = c.blue })
  hl("Special",       { fg = c.bright_magenta })
  hl("SpecialChar",   { fg = c.bright_yellow })
  hl("Tag",           { fg = c.blue })
  hl("Delimiter",     { fg = c.bright_white })
  hl("SpecialComment",{ fg = c.bright_black })
  hl("Debug",         { fg = c.bright_magenta })
  hl("Underlined",    { fg = c.blue, underline = true })
  hl("Bold",          { bold = true })
  hl("Italic",        { italic = true })
  hl("Ignore",        { fg = c.bg })
  hl("Error",         { fg = c.red, bg = "#3d1a1a" })
  hl("Todo",          { fg = c.bg, bg = c.magenta })

  -- Treesitter
  hl("@comment",            { fg = c.bright_black, italic = true })
  hl("@error",              { fg = c.red })
  hl("@none",               {})
  hl("@preproc",            { fg = c.blue })
  hl("@define",             { fg = c.blue })
  hl("@operator",           { fg = c.white })
  hl("@keyword",            { fg = c.magenta })
  hl("@keyword.function",   { fg = c.magenta })
  hl("@keyword.return",     { fg = c.magenta })
  hl("@keyword.operator",   { fg = c.magenta })
  hl("@string",             { fg = c.green })
  hl("@string.regex",       { fg = c.bright_green })
  hl("@string.escape",      { fg = c.bright_yellow })
  hl("@string.special",     { fg = c.bright_yellow })
  hl("@character",          { fg = c.green })
  hl("@character.special",  { fg = c.bright_yellow })
  hl("@number",             { fg = c.bright_red })
  hl("@boolean",            { fg = c.bright_green })
  hl("@float",              { fg = c.bright_red })
  hl("@function",           { fg = c.blue })
  hl("@function.builtin",   { fg = c.blue })
  hl("@function.call",      { fg = c.blue })
  hl("@method",             { fg = c.cyan })
  hl("@method.call",        { fg = c.cyan })
  hl("@constructor",        { fg = c.yellow })
  hl("@parameter",          { fg = c.bright_blue })
  hl("@variable",           { fg = c.fg })
  hl("@variable.builtin",   { fg = c.red })
  hl("@variable.parameter", { fg = c.bright_blue })
  hl("@constant",           { fg = c.bright_red })
  hl("@constant.builtin",   { fg = c.bright_red })
  hl("@constant.macro",     { fg = c.bright_magenta })
  hl("@type",               { fg = c.yellow })
  hl("@type.builtin",       { fg = c.yellow })
  hl("@type.qualifier",     { fg = c.magenta })
  hl("@type.definition",    { fg = c.yellow })
  hl("@storageclass",       { fg = c.magenta })
  hl("@attribute",          { fg = c.bright_magenta })
  hl("@property",           { fg = c.cyan })
  hl("@field",              { fg = c.cyan })
  hl("@namespace",          { fg = c.blue })
  hl("@symbol",             { fg = c.bright_magenta })
  hl("@include",            { fg = c.blue })
  hl("@conditional",        { fg = c.magenta })
  hl("@repeat",             { fg = c.magenta })
  hl("@label",              { fg = c.magenta })
  hl("@exception",          { fg = c.magenta })
  hl("@tag",                { fg = c.blue })
  hl("@tag.delimiter",      { fg = c.bright_white })
  hl("@tag.attribute",      { fg = c.bright_yellow })
  hl("@punctuation.delimiter", { fg = c.bright_white })
  hl("@punctuation.bracket",   { fg = c.bright_white })
  hl("@punctuation.special",   { fg = c.magenta })
  hl("@diff.plus",          { fg = c.green, bg = "#1a2e1a" })
  hl("@diff.minus",         { fg = c.red, bg = "#2e1a1a" })
  hl("@diff.delta",         { fg = c.yellow, bg = "#2e2a1a" })
  hl("@markup.heading",     { fg = c.blue, bold = true })
  hl("@markup.italic",      { italic = true })
  hl("@markup.bold",        { bold = true })
  hl("@markup.underline",   { underline = true })
  hl("@markup.strikethrough",{ strikethrough = true })
  hl("@markup.raw",         { fg = c.green })
  hl("@markup.link",        { fg = c.blue, underline = true })
  hl("@markup.link.url",    { fg = c.blue, underline = true })
  hl("@markup.list",        { fg = c.magenta })
  hl("@markup.quote",       { fg = c.yellow })

  -- UI
  hl("Pmenu",         { fg = c.fg, bg = c.cursorline_bg })
  hl("PmenuSel",      { fg = c.sel_fg, bg = c.sel_bg })
  hl("PmenuSbar",     { bg = c.cursorline_bg })
  hl("PmenuThumb",    { bg = c.bright_black })
  hl("WildMenu",      { fg = c.sel_fg, bg = c.sel_bg })
  hl("StatusLine",    { fg = c.fg, bg = c.cursorline_bg })
  hl("StatusLineNC",  { fg = c.bright_black, bg = c.cursorline_bg })
  hl("TabLine",       { fg = c.bright_black, bg = c.cursorline_bg })
  hl("TabLineSel",    { fg = c.fg, bg = c.bg })
  hl("TabLineFill",   { bg = c.cursorline_bg })
  hl("Title",         { fg = c.blue, bold = true })
  hl("WinSeparator",  { fg = c.cursorline_bg })
  hl("WinBar",        { fg = c.fg, bg = c.cursorline_bg })
  hl("WinBarNC",      { fg = c.bright_black, bg = c.cursorline_bg })
  hl("Folded",        { fg = c.bright_black, bg = c.cursorline_bg })
  hl("FoldColumn",    { fg = c.bright_black })
  hl("SignColumn",    { bg = "NONE" })
  hl("VertSplit",     { fg = c.cursorline_bg })
  hl("ModeMsg",       { fg = c.fg })
  hl("MoreMsg",       { fg = c.blue })
  hl("Question",      { fg = c.blue })
  hl("WarningMsg",    { fg = c.yellow })
  hl("ErrorMsg",      { fg = c.red, bold = true })

  -- Diagnostic
  hl("DiagnosticError",           { fg = c.red })
  hl("DiagnosticWarn",            { fg = c.yellow })
  hl("DiagnosticInfo",            { fg = c.blue })
  hl("DiagnosticHint",            { fg = c.bright_black })
  hl("DiagnosticOk",              { fg = c.green })
  hl("DiagnosticUnderlineError",  { undercurl = true, fg = c.red })
  hl("DiagnosticUnderlineWarn",   { undercurl = true, fg = c.yellow })
  hl("DiagnosticUnderlineInfo",   { undercurl = true, fg = c.blue })
  hl("DiagnosticUnderlineHint",   { undercurl = true, fg = c.bright_black })
  hl("DiagnosticUnderlineOk",     { undercurl = true, fg = c.green })
  hl("DiagnosticVirtualTextError",{ fg = c.red })
  hl("DiagnosticVirtualTextWarn", { fg = c.yellow })
  hl("DiagnosticVirtualTextInfo", { fg = c.blue })
  hl("DiagnosticVirtualTextHint", { fg = c.bright_black })
  hl("DiagnosticFloatingError",   { fg = c.red })
  hl("DiagnosticFloatingWarn",    { fg = c.yellow })
  hl("DiagnosticFloatingInfo",    { fg = c.blue })
  hl("DiagnosticFloatingHint",    { fg = c.bright_black })
  hl("DiagnosticSignError",       { fg = c.red })
  hl("DiagnosticSignWarn",        { fg = c.yellow })
  hl("DiagnosticSignInfo",        { fg = c.blue })
  hl("DiagnosticSignHint",        { fg = c.bright_black })

  -- Diff
  hl("DiffAdd",       { fg = c.green, bg = "#1a2e1a" })
  hl("DiffDelete",    { fg = c.red, bg = "#2e1a1a" })
  hl("DiffChange",    { fg = c.yellow, bg = c.bg })
  hl("DiffText",      { fg = c.yellow, bg = "#3d351a" })

  -- Spell
  hl("SpellBad",      { undercurl = true, fg = c.red })
  hl("SpellCap",      { undercurl = true, fg = c.yellow })
  hl("SpellLocal",    { undercurl = true, fg = c.blue })
  hl("SpellRare",     { undercurl = true, fg = c.magenta })
end

-- File watcher: auto-reload when current-theme.conf changes
local watcher_handle
local debounce

local function start_watcher()
  local ok, handle = pcall(vim.uv.new_fs_event)
  if not ok or not handle then return end
  watcher_handle = handle

  local real_path = vim.fn.resolve(kitty_conf)
  handle:start(real_path, {}, vim.schedule_wrap(function(err)
    if err then return end
    if debounce then
      debounce:stop()
      debounce:close()
    end
    debounce = vim.defer_fn(function()
      M.apply()
    end, 200)
  end))
end

vim.api.nvim_create_user_command("KittyThemeReload", M.apply, { desc = "Reload kitty theme from current-theme.conf" })

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.defer_fn(M.apply, 30)
  end,
  desc = "Apply kitty theme overrides",
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if debounce then pcall(debounce.stop, debounce) end
    if watcher_handle then
      pcall(watcher_handle.stop, watcher_handle)
      pcall(watcher_handle.close, watcher_handle)
    end
  end,
})

M.apply()
vim.defer_fn(start_watcher, 100)

return M
