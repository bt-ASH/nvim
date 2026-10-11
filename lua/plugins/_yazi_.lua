-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 在浮动窗口中打开 yazi（在当前文件所在目录）
      { "<leader>y", "<cmd>Yazi<cr>", desc = "Open yazi at current file (float)" },
      -- 在工作目录打开 yazi
      { "<leader>Y", "<cmd>Yazi cwd<cr>", desc = "Open yazi at cwd" },
      -- 在当前 Neovim 窗口中 toggle yazi
      { "<leader>ty", "<cmd>Yazi toggle<cr>", desc = "Toggle yazi at current file" },
    },
    ---@type yazi.Config
    opts = {
      -- 如果设置为 true，当 yazi 退出时，当前文件会同步到 Neovim（就像在 yazi 中打开文件一样）
      open_for_directories = false,

      -- 浮动窗口配置
      floating_window_scaling_factor = 0.9, -- 浮动窗口大小比例

      -- 显示隐藏文件（点文件）
      show_hidden_files = true,

      -- yazi 浮动窗口透明度
      yazi_floating_window_winblend = 0,

      -- 选择多个文件后的行为
      multiple_file_selection = {
        enabled = true,
        action = "copy_relative_paths", -- 可选: "copy_relative_paths", "copy_absolute_paths", "copy_filenames", "send_to_quickfix"
      },

      -- 映射
      mappings = {
        -- 在 yazi 中按 `<Esc>` 时只隐藏 yazi 窗口（不退出）
        hide_on_escape = false,

        -- 自定义快捷键
        keymap = {},
      },
    },
  },
}