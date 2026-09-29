return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        -- snacks의 Lazygit 자동 테마 설정 off
        configure = false,
      },
      indent = {
        animate = {
          enabled = false, -- 들여쓰기 선 애니메이션 끄기
        },
      },
      scroll = {
        enabled = false, -- 부드러운 스크롤 끄기
      },
    },
  },
}
