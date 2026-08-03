-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

-- 커서가 위/아래로 이동할 때 화면 가장자리에 남기는 최소 줄 수 (LazyVim 기본값 4 -> 8)
vim.opt.scrolloff = 8

-- SSH 세션에서는 클립보드를 OSC 52로 전달
-- 원격 서버엔 pbcopy가 없어 기본 클립보드 provider가 동작하지 않으므로,
-- SSH로 접속했을 때만 OSC 52 provider로 전환해 로컬 터미널 클립보드까지 복사되게 함
-- (tmux.conf의 set-clipboard on + copy-pipe-and-cancel과 짝을 이루는 설정)
if os.getenv("SSH_TTY") then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
