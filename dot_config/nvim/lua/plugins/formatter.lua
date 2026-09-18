return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        typescript = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        vue = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        svelte = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        json = { "oxfmt", "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        kotlin = { "ktlint" },
        java = { "google-java-format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
      formatters = {
        -- oxc extra config markers not found in this project's root -> skip, fall through to prettier
        oxfmt = { require_cwd = true },
      },
    },
  },
}
