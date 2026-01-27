require("lze").load {
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
    "oil.nvim",
    lazy = false,
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Oil in parent directory" },
    },
    before = function()
      require("oil").setup({ default_file_explorer = true })
    end,
  },
  {
    "mini.pick",
    keys = {
      { "<leader>fs", ":Pick files<CR>", desc = "Fuzzy file picker" },
      { "<leader>fh", ":Pick help<CR>", desc = "Fuzzy help category picker" },
    },
    after = function()
      require("mini.pick").setup()
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
    lazy = true,
    ft = "markdown",
    dependencies = {
      "plenary.nvim",
      "mini.pick",
      "nvim-treesitter",
    },
    after = require "plugins.obsidian",
  },

  -- Extras
  {
    "smear-cursor.nvim",
    after = require "plugins.smear",
  },
}
