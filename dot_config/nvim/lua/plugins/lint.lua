return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost", "InsertLeave" },
  opts = {
    linters_by_ft = {
      markdown = { "markdownlint" },
      python = { "ruff" },
    },
  },
  config = function() end,
}
