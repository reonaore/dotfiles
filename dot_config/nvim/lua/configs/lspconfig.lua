require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "lua_ls", "yamlls", "ty", "kotlin_lsp" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
