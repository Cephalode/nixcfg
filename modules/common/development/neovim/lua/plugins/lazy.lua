local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  return
end

lazy.setup({
  {
    "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.lsp")
    end,
  },
  {
    "nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
  },
  {
    "markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  },
  {
    "obsidian.nvim",
    ft = { "markdown" },
    -- dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.markdown")
    end,
  },
  {
    "oil.nvim",
    cmd = { "Oil" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil parent directory: },
    },
    config = function()
      require("oil").setup()
    end,
  },
  {
    "fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup()
    end,
  },
})
