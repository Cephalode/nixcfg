return {
  {
    "mini.nvim",
    auto_enable = true,
    lazy = false,
    after = function()
      require("mini.pick").setup()
      require("mini.statusline").setup()
      require("mini.animate").setup({ scroll = { enable = false }, resize = { enable = false } })
      vim.keymap.set("n", "<leader>ff", function() require("mini.pick").builtin.files() end, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", function() require("mini.pick").builtin.grep_live() end, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", function() require("mini.pick").builtin.buffers() end, { desc = "Buffers" })
    end,
  },
}
