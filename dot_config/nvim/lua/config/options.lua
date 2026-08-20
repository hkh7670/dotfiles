-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Snacks animation 비활성화
vim.g.snacks_animate = false

-- 커서 위/아래에 유지할 최소 줄 수
vim.opt.scrolloff = 8

-- SSH + tmux 환경에서는 tmux clipboard provider를 사용한다.
--
-- 복사 경로:
-- Neovim
--   → tmux clipboard provider
--   → tmux
--   → OSC 52
--   → SSH
--   → 로컬 터미널
--   → 로컬 OS Clipboard
--
-- SSH이지만 tmux를 사용하지 않는 경우에는 LazyVim 기본 설정을 그대로 두어
-- Neovim의 OSC 52 자동 감지를 사용한다.
if vim.env.SSH_CONNECTION and vim.env.TMUX then
  vim.g.clipboard = "tmux"
  vim.opt.clipboard = "unnamedplus"
end
