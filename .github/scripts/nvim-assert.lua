local errors = {}

if vim.v.errmsg ~= "" then
  table.insert(errors, "Neovim reported an error during startup: " .. vim.v.errmsg)
end

local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  table.insert(errors, "lazy.nvim did not load: " .. tostring(lazy))
elseif lazy.stats().count == 0 then
  table.insert(errors, "lazy.nvim loaded no plugins")
else
  local config = require("lazy.core.config")
  for name, plugin in pairs(config.plugins) do
    for _, task in ipairs(plugin._.tasks or {}) do
      if task:has_errors() then
        table.insert(errors, "lazy.nvim task failed for " .. name)
      end
    end
  end
end

if #errors > 0 then
  io.stderr:write(table.concat(errors, "\n") .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa")
end
