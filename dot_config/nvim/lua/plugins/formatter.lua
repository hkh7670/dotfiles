return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        kotlin = { "ktlint" },
        java = { "google-java-format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
    },
  },
}
