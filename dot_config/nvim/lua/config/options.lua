-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- 커서 위/아래에 유지할 최소 줄 수
vim.opt.scrolloff = 8

-- 맞춤법 검사에서 한글 등 동아시아 문자를 제외한다.
-- LazyVim은 markdown/text에서 spell을 켜는데, 영어 사전만 쓰면 한글 단어가 모두 오류로 표시된다.
vim.opt.spelllang = { "en", "cjk" }

-- 클립보드 (tmux 환경)
--
-- 복사: nvim → tmux 버퍼 → OSC 52 → (SSH) → 터미널 → 터미널이 실행 중인 머신의 OS 클립보드
-- 붙여넣기: 호출 시점에 tmux 세션이 SSH로 attach되어 있으면 tmux 버퍼,
--           아니면 OS 클립보드(pbpaste)를 읽는다.
--           SSH일 때 로컬 OS 클립보드 내용은 터미널 붙여넣기(Cmd+V)로 넣는다.
--
-- SSH 여부를 nvim 프로세스의 $SSH_CONNECTION으로 판단하지 않는 이유:
-- 로컬에서 만든 pane에 나중에 SSH로 attach하면, tmux 세션 환경만 갱신되고
-- 이미 실행 중인 셸과 nvim의 환경변수는 그대로 남는다.
--
-- 내장 tmux provider(vim.g.clipboard = "tmux")는 붙여넣을 때
-- refresh-client -l로 OSC 52 읽기를 요청하는데, SSH 지연이 있으면
-- 터미널의 base64 응답이 입력에 섞이므로 직접 정의한다.
-- (https://github.com/neovim/neovim/discussions/29350)
--
-- 그 외 환경은 LazyVim 기본값을 따른다.
-- - 로컬(tmux 없음): unnamedplus + OS 클립보드
-- - SSH(tmux 없음): clipboard = "", "+y 로 복사하면 OSC 52 사용
if vim.env.TMUX then
  local copy = { "tmux", "load-buffer", "-w", "-" }
  local paste = { "tmux", "save-buffer", "-" }
  if vim.fn.executable("pbpaste") == 1 then
    -- tmux는 로컬 attach 시 세션 환경의 SSH_CONNECTION을 "-SSH_CONNECTION"(제거됨)으로 표시한다.
    paste = {
      "sh",
      "-c",
      "if tmux show-environment SSH_CONNECTION 2>/dev/null | grep -q '^SSH_CONNECTION='; "
        .. "then tmux save-buffer -; else pbpaste; fi",
    }
  end
  vim.g.clipboard = {
    name = "tmux",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
  vim.opt.clipboard = "unnamedplus"
end
