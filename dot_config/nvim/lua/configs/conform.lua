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
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
