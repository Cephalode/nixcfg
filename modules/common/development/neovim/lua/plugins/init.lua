require("lze").load {
  -- Dependencies
  { "plenary.nvim", lazy = false},
  { "nui.nvim", lazy = false},
  { "nvim-web-devicons", lazy = false},

  -- Diagnostics
  {
    "vim-startuptime",
    cmd = "StartupTime",
    before = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- Navigation
  {
    "nvim-treesitter",
    lazy = false,
    build = {
      ":TSUpdate",
      require "plugins.treesitter",
    },
  },
  {
    "nvim-lspconfig",
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function()
      vim.lsp.config('*', {
        on_attach = require('myLuaConf.LSPs.on_attach'),
      })
      require "plugins.lsp"
    end,
  },
  {
    "oil.nvim",
    lazy = false,
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Oil in parent directory" },
    },
    after = function()
      require("oil").setup()
    end,
  },
  {
    "mini.pick",
    lazy = false,
    keys = {
      { "<leader>fs", ":Pick files<CR>", desc = "Fuzzy file picker" },
      { "<leader>fh", ":Pick help<CR>", desc = "Fuzzy help category picker" },
    },
    after = function()
      require("mini.pick").setup()
    end,
  },
  {
    "neo-tree.nvim",
    dependencies = {
      "plenary.nvim",
      "nui.nvim",
      "nvim-web-devicons",
    },
    keys = {
      { "<leader>t", ":Neotree<CR>", desc = "Tree file explorer" },
    },
    after = function()
      require("neo-tree").setup({})
    end,
  },

  -- Notes (markdown)
  {
    "markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = "cd app && bun install",
    after = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
  {
    "obsidian.nvim",
    ft = "markdown",
    dependencies = {
      "plenary.nvim",
      "nvim-treesitter",
      "mini.pick",
    },
    keys = {
    },
    after = require "plugins.obsidian",
  },

  -- Extras
  {
    "smear-cursor.nvim",
    after = require "plugins.smear",
  },
}
