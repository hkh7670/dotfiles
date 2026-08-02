-- 1. kotlin-lsp CLI 설치 (brew 사용시)
-- brew install JetBrains/utils/kotlin-lsp

-- 2. LazyVim의 기본 kotlin_language_server 비활성화
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = false, -- 기본 서버 끄기
      },
    },
  },

  -- 3. 수동으로 kotlin-lsp 등록
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

      if not configs.kotlin_lsp then
        configs.kotlin_lsp = {
          default_config = {
            cmd = { "kotlin-lsp", "--stdio" }, -- PATH에 심볼릭 링크된 실행파일
            filetypes = { "kotlin" },
            root_dir = require("lspconfig.util").root_pattern(
              "settings.gradle",
              "settings.gradle.kts",
              "pom.xml",
              ".git"
            ),
          },
        }
      end

      lspconfig.kotlin_lsp.setup({})
    end,
  },
}
