return {
  {
    "conform.nvim",
    auto_enable = true,
    keys = { { "<leader>cf", desc = "Code format" } },
    after = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "nixfmt" },
          python = { "ruff_format" },
          rust = { "rustfmt" },
          go = { "gofumpt" },
          javascript = { "biome" },
          typescript = { "biome" },
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        conform.format({ lsp_fallback = true, timeout_ms = 1000 })
      end, { desc = "Code format" })
    end,
  },
}
