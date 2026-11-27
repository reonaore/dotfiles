return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require("configs.conform"),
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("configs.lspconfig")
    end,
  },
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },
  { "L3MON4D3/LuaSnip", event = "InsertEnter" },
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "folke/which-key.nvim", event = "VeryLazy" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "html",
        "css",
        "bash",
        "kotlin",
        "markdown",
        "lua",
        "zsh",
        "python",
        "javascript",
        "jsx",
        "typescript",
        "tsx",
      },
    },
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
}
