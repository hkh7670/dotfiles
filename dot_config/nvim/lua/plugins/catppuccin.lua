return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- 다른 플러그인보다 먼저 로드
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha 중 선택
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = true,
        -- LazyVim이 사용하는 플러그인들과의 통합 옵션
        native_lsp = {
          enabled = true,
        },
      },
    },
  },

  -- LazyVim에게 기본 컬러스킴으로 지정
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
