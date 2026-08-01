-- -------------------------------
-- 플러그인 매니저 부트스트랩 (lazy.nvim)
-- https://lazy.folke.io/installation
-- -------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- <leader> 키맵(lua/config/keymaps.lua)이 참조하므로 plugin setup 전에 미리 지정
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  spec = {
    -- lua/plugins/*.lua 에 있는 모든 플러그인 스펙을 자동으로 불러옴
    { import = "plugins" },
  },
--  install = { colorscheme = { "onedark" } },
  checker = { enabled = true },
})
