return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost", "InsertLeave" },
  opts = {
    -- linters = {},
    linters_by_ft = {
      markdown = { "markdownlint" },
    },
  },
  config = function()
    local lint = require "lint"
    lint.linters_by_ft = {
      markdown = { "markdownlint" },
    }
    lint.linters.cspell = require("lint.util").wrap(lint.linters.cspell, function(params)
      params.severity = vim.diagnostic.severity.HINT
      return params
    end)
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
      callback = function()
        lint.try_lint()
        lint.try_lint "cspell"
      end,
    })
  end,
}
