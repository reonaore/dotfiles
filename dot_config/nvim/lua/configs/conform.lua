local options = {
  formatters_by_ft = {
    lua = { "lua_ls" },
    markdown = { "markdownlint" },
    zsh = { "beautysh" },
    bash = { "beautysh" },
    sh = { "beautysh" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 2000,
    lsp_format = "fallback",
  },
}

return options
