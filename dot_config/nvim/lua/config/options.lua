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
--
-- SSH_CONNECTION도 함께 확인하는 이유:
-- tmux의 update-environment 기본 목록에 SSH_TTY가 없어서, tmux 안에서 실행한
-- nvim에는 SSH_TTY가 전달되지 않는다. SSH_CONNECTION은 그 목록에 있어 유지되므로
-- 두 변수를 모두 확인해야 tmux 세션 안에서도 OSC 52가 켜진다.
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  local osc52 = require("vim.ui.clipboard.osc52")

  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    -- paste는 OSC 52로 터미널에 질의하지 않는다. 대부분의 터미널이 보안상 클립보드
    -- 읽기 요청에 응답하지 않아 붙여넣기마다 타임아웃까지 멈추기 때문.
    -- 대신 마지막으로 yank한 내용을 돌려준다.
    -- (로컬 PC 클립보드 → nvim 방향은 터미널 자체 붙여넣기 Cmd+V 사용)
    paste = {
      ["+"] = function()
        return vim.split(vim.fn.getreg(""), "\n")
      end,
      ["*"] = function()
        return vim.split(vim.fn.getreg(""), "\n")
      end,
    },
  }

  -- LazyVim은 SSH 세션에서 clipboard 옵션을 ""로 비워둔다 (lazyvim/config/options.lua:57).
  -- 그래서 그냥 y를 눌러도 + 레지스터를 거치지 않아 위 provider가 호출되지 않는다.
  -- 옵션을 되돌리려 하면 LazyVim이 이 파일보다 나중에 적용되어 다시 덮어쓰므로,
  -- 로드 순서와 무관하게 yank 이벤트에서 직접 OSC 52로 보낸다.
  -- 붙여넣기 동작에는 영향을 주지 않는다.
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("osc52_yank", { clear = true }),
    callback = function()
      if vim.v.event.operator == "y" then
        osc52.copy("+")(vim.v.event.regcontents)
      end
    end,
  })
end
