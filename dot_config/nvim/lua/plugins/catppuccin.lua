-- ~/.config/nvim/lua/plugins/catppuccin-lualine.lua
-- lazy.nvim 플러그인 스펙: catppuccin 테마 + lualine 연동
-- 사용법: lazy.nvim의 plugins 디렉토리(보통 lua/plugins/)에 이 파일을 그대로 저장하면 됩니다.

return {
  -- 1) Catppuccin 테마
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- 다른 플러그인보다 먼저 로드되어야 색상이 제대로 적용됨
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha 중 선택
      transparent_background = false,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = true,
        telescope = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 2) lualine에 catppuccin 테마 적용
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin-nvim",
        icons_enabled = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
}
