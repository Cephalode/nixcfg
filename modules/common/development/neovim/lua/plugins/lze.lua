require("lze").load {
  -- Navigation
  {
    "nvim-treesitter",
    lazy = false,
    build = ":TSUpdate"
  },
  {
    "oil.nvim",
    keys = {
      { "<leader>e", "<CMD>Oil<CR>", desc = "Oil in parent directory" },
    },
    after = function()
      require("oil").setup()
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
    build = "cd app && bun install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
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
    after = function()
      require "plugins.smear"
    end,
  },
}
