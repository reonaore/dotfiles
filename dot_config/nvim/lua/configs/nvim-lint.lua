local lint = require "lint"
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
