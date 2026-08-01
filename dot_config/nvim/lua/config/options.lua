--- ------------------------------
-- 에디터 기본 설정
-- -------------------------------
local opt = vim.opt
opt.syntax = "on"                       -- 문법 강조 활성화 (기본 문법 하이라이팅)
opt.hlsearch = true                     -- 검색 결과 강조 표시
opt.number = true                       -- 줄 번호 표시
opt.autoindent = true                   -- 자동 들여쓰기 활성화
opt.tabstop = 4                         -- Tab 문자의 폭 (공백 기준)
opt.softtabstop = 4                     -- Soft Tab Stop (백스페이스 시 기준 폭)
opt.cindent = true                      -- C 스타일 들여쓰기 규칙 사용
opt.laststatus = 2                      -- 항상 상태줄 표시
opt.shiftwidth = 4                      -- >> 또는 << 시 들여쓰기 폭
opt.showmatch = true                    -- 여는 괄호 입력 시 닫는 괄호 자동 강조
opt.ignorecase = true                   -- 검색 시 기본적으로 대소문자 무시 (smartcase가 동작하려면 필수)
opt.smartcase = true                    -- 검색어에 대문자가 섞이면 대소문자 구분해서 검색
opt.smarttab = true                     -- Tab을 상황에 맞게 처리
opt.smartindent = true                  -- 코드 구조에 맞춰 자동 들여쓰기
opt.expandtab = true                    -- Tab 입력 시 공백으로 변환
opt.ruler = true                        -- 상태줄에 커서 위치 표시
opt.fileencodings = { "utf8", "euc-kr" } -- 파일 인코딩 감지 순서 (우선 UTF-8)
opt.showmode = false                    -- -- INSERT -- 등 모드 표시 비활성화 (lightline이 대체함)
opt.clipboard = "unnamedplus"           -- 시스템 클립보드와 연동 (복사/붙여넣기 공유)
opt.termguicolors = true                -- True Color 지원 (256색 이상 사용 가능)
opt.relativenumber = true               -- 현재 줄은 절대 번호로, 나머지 줄은 상대적인 거리로 표시해 줍니다. 10j (10줄 아래로) 같은 이동이 매우 직관적이 됩니다.
opt.incsearch = true                    -- 검색어를 입력하는 동안 실시간으로 일치하는 패턴을 보여줍니다.
opt.undofile = true                     -- 파일을 닫았다가 다시 열어도 수정 내역(undo)이 유지됩니다.
opt.scrolloff = 8                       -- 커서가 화면 위/아래 8줄 근처로 가면 자동으로 스크롤을 시작하여 항상 주변 코드를 넓게 볼 수 있습니다


-- -------------------------------
-- 실용적인 기본 세팅 (많이 쓰이는 값들)
-- -------------------------------
opt.mouse = "a"                         -- 터미널에서도 마우스로 클릭/스크롤/드래그 선택 가능
opt.wrap = false                        -- 긴 줄을 자동 줄바꿈하지 않고 가로로 스크롤
opt.splitright = true                   -- 세로 분할(:vsplit) 시 새 창이 오른쪽에 생성
opt.splitbelow = true                   -- 가로 분할(:split) 시 새 창이 아래쪽에 생성
opt.signcolumn = "yes"                  -- sign column을 항상 표시해 텍스트가 좌우로 밀리는 현상 방지
opt.updatetime = 300                    -- CursorHold 등 이벤트 반응 속도 (기본 4000ms -> 300ms)
opt.timeoutlen = 500                    -- 다중 키 조합 입력 대기 시간 단축 (기본 1000ms -> 500ms)
opt.completeopt = "menuone,noselect"    -- 내장 자동완성(omnifunc/dictionary 등) 메뉴 동작 개선
opt.swapfile = false                    -- 스왑 파일 생성 안 함 (undofile로 대체)
opt.backup = false                      -- 백업 파일 생성 안 함
opt.writebackup = false                 -- 저장 중 임시 백업 파일 생성 안 함

-- nvim_set_hl은 넘긴 테이블로 하이라이트 그룹을 통째로 교체하므로
-- 기존 정의(onedark가 설정한 fg 등)를 먼저 읽어와 병합해야 글자색이 날아가지 않는다
--local function set_hl_override(group, override)
--  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
--  vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", hl, override))
--end

-- 라인 강조
-- opt.cursorline = true
-- set_hl_override("CursorLine", { ctermbg = 238, bg = "#3C3C3C" })

-- 배경 투명화 설정 (깜빡임 현상 완화)
-- 터미널 자체 투명도(알파)를 쓰지 않으면 효과가 없어 주석 처리함.
-- 터미널 투명도를 다시 쓰게 되면 아래 블록의 주석만 풀면 됨.
-- local transparent_groups = {
--   "Normal",
--   "NonText",
--   "EndOfBuffer",
--   "SignColumn",
--   "FoldColumn",
--   "LineNr",
--   "CursorLineNr",
-- }
-- for _, group in ipairs(transparent_groups) do
--   set_hl_override(group, { bg = "none", ctermbg = "none" })
-- end
