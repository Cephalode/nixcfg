return {
  {
    "which-key.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("which-key").setup()
    end,
  },
  {
    "fidget.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("fidget").setup({})
    end,
  },
  {
    "nvim-surround",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "todo-comments.nvim",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("todo-comments").setup()
    end,
  },
  {
    "undotree",
    auto_enable = true,
    cmd = { "UndotreeToggle" },
  },
  -- Colorscheme trigger
  {
    "trigger_colorscheme",
    event = "VimEnter",
    load = function()
      vim.schedule(function()
        pcall(vim.cmd.colorscheme, nixInfo("habamax", "settings", "colorscheme"))
      end)
    end,
  },
}
