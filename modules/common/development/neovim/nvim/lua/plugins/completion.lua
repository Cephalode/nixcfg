return {
  {
    "blink.cmp",
    auto_enable = true,
    event = "DeferredUIEnter",
    after = function()
      require("blink.cmp").setup({
        keymap = { preset = "default" },
        signature = { enabled = true },
        sources = {
          default = { "lsp", "path", "buffer" },
        },
      })
    end,
  },
}
