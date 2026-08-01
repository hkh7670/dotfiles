-- -------------------------------
-- 파일 타입에 따른 들여쓰기 설정
-- -------------------------------
local filetype_settings = vim.api.nvim_create_augroup("filetype_settings", { clear = true })
-- JS와 JSON 파일은 2칸으로 설정
vim.api.nvim_create_autocmd("FileType", {
  group = filetype_settings,
  pattern = { "javascript", "json", "typescript", "ruby", "html", "css", "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})
