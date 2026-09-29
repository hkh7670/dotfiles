-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- 커서 위/아래에 유지할 최소 줄 수
vim.opt.scrolloff = 8

-- 클립보드 (SSH + tmux 환경)
--
-- 복사: nvim → tmux 버퍼 → OSC 52 → SSH → 로컬 터미널 → 로컬 OS 클립보드
-- 붙여넣기: tmux 버퍼만 읽는다. 로컬 OS 클립보드 내용은 터미널 붙여넣기(Cmd+V)로 넣는다.
--
-- 내장 tmux provider(vim.g.clipboard = "tmux")는 붙여넣을 때
-- refresh-client -l로 OSC 52 읽기를 요청하는데, SSH 지연이 있으면
-- 터미널의 base64 응답이 입력에 섞이므로 직접 정의한다.
-- (https://github.com/neovim/neovim/discussions/29350)
--
-- 그 외 환경은 LazyVim 기본값을 따른다.
-- - 로컬: unnamedplus + OS 클립보드
-- - SSH(tmux 없음): clipboard = "", "+y 로 복사하면 OSC 52 사용
if vim.env.SSH_CONNECTION and vim.env.TMUX then
  local copy = { "tmux", "load-buffer", "-w", "-" }
  local paste = { "tmux", "save-buffer", "-" }
  vim.g.clipboard = {
    name = "tmux",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
  vim.opt.clipboard = "unnamedplus"
end
