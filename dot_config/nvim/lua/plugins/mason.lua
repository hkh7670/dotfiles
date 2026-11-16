-- ktlint, google-java-format은 다른 에디터와 같은 버전을 쓰도록 mise로 설치한다.
-- LazyVim kotlin extra가 ensure_installed에 ktlint를 추가하므로 목록에서 제외한다.
local MISE_MANAGED = { ktlint = true, ["google-java-format"] = true }

return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    local ensure_installed = vim.list_extend(vim.deepcopy(opts.ensure_installed or {}), {
      "stylua",
      "shfmt",
      "black",
      "isort",
      "prettierd",
      "clang-format",
    })
    opts.ensure_installed = vim.tbl_filter(function(name)
      return not MISE_MANAGED[name]
    end, ensure_installed)
  end,
}
