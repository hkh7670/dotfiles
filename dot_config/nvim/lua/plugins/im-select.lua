return {
  "keaising/im-select.nvim",
  event = "VeryLazy",
  config = function()
    require("im_select").setup({
      -- 아래 주석을 풀고 im-select 바이너리가 설치된 실제 절대 경로를 적어줍니다.
      default_command = "/opt/homebrew/bin/im-select", -- macOS 예시
      -- default_command = "C:\\tools\\im-select.exe",   -- Windows 예시
    })
  end,
}
