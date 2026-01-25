local ok, lazy = pcall(require, "lze")
if not ok then
  return
end

lazy.load({
  {
    name = "nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.lsp")
    end,
  },
  {
    name = "nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
  },
  {
    name = "markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  },
  {
    name = "obsidian.nvim",
    ft = { "markdown" },
    -- dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.markdown")
    end,
  },
  {
    name = "oil.nvim",
    cmd = { "Oil" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil parent directory" },
    },
    config = function()
      require("plugins.oil")
    end,
  },
  {
    name = "fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup()
    end,
  },
})
