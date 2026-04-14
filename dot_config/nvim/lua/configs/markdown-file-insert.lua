local hook = function()
  local fzf = require("fzf-lua")
  fzf.complete_file({
    cmd = "rg --files",
    winopts = { preview = { hidden = true } }
  })
end

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.md",
  callback = function()
    vim.keymap.set("i", "@", hook, { silent = true, desc = "Insert file path" })
  end,
})
