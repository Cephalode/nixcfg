return {
  {
    "excalidraw.nvim",
    auto_enable = true,
    ft = "markdown",
    cmd = { "Excalidraw" },
    after = function()
      require("excalidraw").setup({})
    end,
  },
}
