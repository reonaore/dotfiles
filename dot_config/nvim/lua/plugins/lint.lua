return {
  "mfussenegger/nvim-lint",
  event = { "BufWritePost", "BufReadPost", "InsertLeave" },
  opts = {
    linters_by_ft = {
      markdown = { "markdownlint" },
    },
  },
  config = function()
    require "configs.nvim-lint"
  end,
}
