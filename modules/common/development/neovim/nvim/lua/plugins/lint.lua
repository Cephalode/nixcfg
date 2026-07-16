return {
  {
    "nvim-lint",
    auto_enable = true,
    event = "FileType",
    after = function()
      require("lint").linters_by_ft = {
        python = { "ruff" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },
}
