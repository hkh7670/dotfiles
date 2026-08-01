-- -------------------------------
-- 자주 쓰는 키맵
-- -------------------------------
local map = vim.keymap.set

-- 창(윈도우) 간 이동
map("n", "<C-h>", "<C-w>h", { desc = "왼쪽 창으로 이동" })
map("n", "<C-j>", "<C-w>j", { desc = "아래쪽 창으로 이동" })
map("n", "<C-k>", "<C-w>k", { desc = "위쪽 창으로 이동" })
map("n", "<C-l>", "<C-w>l", { desc = "오른쪽 창으로 이동" })

-- 비주얼 모드에서 들여쓰기/내어쓰기 후에도 선택 영역 유지
map("v", "<", "<gv", { desc = "내어쓰기 후 선택 유지" })
map("v", ">", ">gv", { desc = "들여쓰기 후 선택 유지" })

-- 비주얼 모드에서 선택한 줄을 통째로 위/아래로 이동
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "선택한 줄 아래로 이동" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "선택한 줄 위로 이동" })

-- 검색 하이라이트 끄기
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "검색 하이라이트 끄기" })

-- 반 페이지 스크롤 시 커서를 화면 중앙에 유지
map("n", "<C-d>", "<C-d>zz", { desc = "반 페이지 아래로 스크롤 (커서 중앙 유지)" })
map("n", "<C-u>", "<C-u>zz", { desc = "반 페이지 위로 스크롤 (커서 중앙 유지)" })

-- fzf.vim 단축키
map("n", "<leader>ff", "<cmd>Files<CR>", { desc = "파일 찾기" })
map("n", "<leader>fg", "<cmd>Rg<CR>", { desc = "본문 내용 검색 (ripgrep 필요)" })
map("n", "<leader>fb", "<cmd>Buffers<CR>", { desc = "열린 버퍼 목록" })
