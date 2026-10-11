-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- themes: https://vimcolorschemes.com/

-- Custom foldtext function with syntax highlighting
-- Source: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, start_text, lnum, offset)
  offset = offset or 0
  local text = ""
  local hl
  for i = 1, #start_text do
    local char = start_text:sub(i, i)
    local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, offset + i - 1)
    local outmost_highlight = captured_highlights[#captured_highlights]
    if outmost_highlight then
      local new_hl = "@" .. outmost_highlight.capture
      if new_hl ~= hl then
        -- as soon as new hl appears, push substring with current hl to table
        table.insert(result, { text, hl })
        text = ""
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end

function _G.custom_foldtext()
  -- 定义 icon+行号 的自定义高亮组（斜体）
  vim.api.nvim_set_hl(0, "CustomFoldText", { fg = "#000000", bg = "#66D9EF", italic = false })
  local start_text = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local nline = vim.v.foldend - vim.v.foldstart
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  table.insert(result, { "  " .. nline .. " ", "CustomFoldText" })
  -- 检查折叠结束行是否包含闭合符号
  -- 常见的闭合符号：end, fi, done, esac, }, ], ), >, ", ', `
  local patterns = {
    "end[f]?", -- end, endif (vim, lua, ruby, etc.)
    "fi", -- if 结束
    "done", -- do/for/while 结束
    "esac", -- case 结束 (shell)
    "[f]unc[tion]?", -- function/endfunction (vim, etc.)
    "endclass", -- class 结束
    "endstruct", -- struct 结束
    "[%])}]+[,;]?", -- }, ], ) 后跟可选的逗号或分号
    "['\"`]", -- 引号
    "</[%w%-]*>", -- HTML/XML 标签结束
  }
  local endline = vim.fn.getline(vim.v.foldend)
  for _, pattern in ipairs(patterns) do
    if vim.trim(endline):find(pattern) == 1 then
      -- 添加结束行的内容（带语法高亮）
      -- 需要计算前导空白作为 offset，以便正确获取语法高亮
      local offset = #(endline:match "^(%s+)" or "")
      local trimmed_endline = vim.trim(endline)
      fold_virt_text(result, trimmed_endline, vim.v.foldend - 1, offset)
      break
    end
  end
  -- 计算当前文本宽度，添加点号填充到行尾
  local current_width = 0
  for _, chunk in ipairs(result) do
    current_width = current_width + vim.fn.strdisplaywidth(chunk[1])
  end
  local win_width = vim.fn.winwidth(0)
  if current_width < win_width then
    local fill_text = string.rep(".", win_width - current_width)
    table.insert(result, { fill_text, "Folded" })
  end
  return result
end

return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- 配色交给 Noctalia 的 base16 模板（matugen.lua），AstroUI 不设 colorscheme。
      -- 原值为 "catppuccin"，2026-10-11 移除 catppuccin 后置为 false；
      -- 若保持旧值，插件缺失时每次启动都会弹 "Error setting up colorscheme"。
      colorscheme = false,
      status = {
        attributes = {
          buffer_active = { bold = false, italic = false },
        },
        colors = function(colors)
          -- buffer 配色来自 matugen.lua 的 M.status（跟随壁纸）
          -- 模板: ~/.config/noctalia/templates/nvim.lua
          -- 2026-10-11 之前由 lua/user/matugen-astroui.lua 单独生成，现已合并进 matugen.lua。
          local ok, matugen = pcall(require, "matugen")
          local status = ok and type(matugen) == "table" and matugen.status or nil
          local fallback = {
            buffer_fg = "#a5adce",
            buffer_active_bg = "#a6d189",
            buffer_active_fg = "#000000",
            buffer_visible_bg = "#86a189",
            buffer_visible_fg = "#000000",
            buffer_path_fg = "#51576d",
            buffer_active_path_fg = "#51576d",
            buffer_visible_path_fg = "#51576d",
          }
          return vim.tbl_extend("force", colors, status or fallback)
        end,
        components = {
          tabline_file_info = {
            file_icon = false,
            close_button = false, -- 隐藏关闭按钮(x号)
            padding = { left = 1, right = 1 },
          },
        },
      },
      -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      highlights = {
        -- init = { -- this table overrides highlights in all themes
        --   -- Normal = { bg = "#000000" },
        --   Folded = { bg = nil }, -- 配置折叠代码块背景色为空（默认是有一个蒙版一样的）
        -- },
        astrodark = { -- a table of overrides/changes when applying the astrotheme theme
          -- Normal = { bg = "#000000" },
        },

        init = function()
          local get_hlgroup = require("astroui").get_hlgroup
          -- get highlights from highlight groups
          local bg = get_hlgroup("Normal").bg
          local bg_alt = get_hlgroup("Visual").bg
          local green = get_hlgroup("String").fg
          local red = get_hlgroup("Error").fg
          -- return a table of highlights for snacks.picker based on
          -- colors retrieved from highlight groups
          return {
            Folded = { bg = nil }, -- 配置折叠代码块背景色为空（默认是有一个蒙版一样的）
            SnacksPickerBorder = { fg = bg_alt, bg = bg },
            SnacksPicker = { bg = bg },
            SnacksPickerPreviewBorder = { fg = bg, bg = bg },
            SnacksPickerPreview = { bg = bg },
            SnacksPickerPreviewTitle = { fg = bg, bg = green },
            SnacksPickerBoxBorder = { fg = bg, bg = bg },
            SnacksPickerInputBorder = { fg = bg, bg = bg },
            SnacksPickerInputSearch = { fg = red, bg = bg },
            SnacksPickerListBorder = { fg = bg, bg = bg },
            SnacksPickerList = { bg = bg },
            SnacksPickerListTitle = { fg = bg, bg = bg },
          }
        end,
      },
      -- Icons can be configured throughout the interface
      icons = {
        -- configure the loading of the lsp in the status line
        LSPLoading1 = "⠋",
        LSPLoading2 = "⠙",
        LSPLoading3 = "⠹",
        LSPLoading4 = "⠸",
        LSPLoading5 = "⠼",
        LSPLoading6 = "⠴",
        LSPLoading7 = "⠦",
        LSPLoading8 = "⠧",
        LSPLoading9 = "⠇",
        LSPLoading10 = "⠏",
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        set_custom_foldtext = {
          {
            event = { "VimEnter", "FileType" },
            pattern = "*",
            callback = function()
              -- 只在支持 treesitter 的文件类型中设置自定义 foldtext
              if vim.o.foldtext == "" and pcall(vim.treesitter.get_parser) then
                vim.opt_local.foldtext = "v:lua.custom_foldtext()"
                -- 移除折叠后的填充字符
                vim.opt_local.fillchars:append { fold = " " }
                -- 如果支持 foldfillchars（Neovim 0.10+）
                if vim.fn.exists "&foldfillchars" == 1 then
                  vim.opt_local.foldfillchars = { open = " ", close = " ", fold = " " }
                end
              end
            end,
            desc = "Set custom foldtext function with syntax highlighting",
          },
        },
      },
      options = {
        opt = {
          -- 移除折叠后的填充字符
          fillchars = {
            eob = " ",
            fold = " ",
            foldopen = "",
            foldclose = "",
            foldsep = " ",
          },
        },
      },
    },
  },
}
