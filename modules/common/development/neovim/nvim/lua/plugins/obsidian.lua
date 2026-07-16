return {
  {
    "obsidian.nvim",
    auto_enable = true,
    ft = "markdown",
    after = function()
      -- Vault path from nix (info.obsidian_vault) or auto-detect
      local vault = nixInfo(nil, "info", "obsidian_vault")
      if not vault then
        local candidates = {
          vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents"),
          vim.fn.expand("~/notes"),
        }
        for _, path in ipairs(candidates) do
          if vim.uv.fs_stat(path) then vault = path; break end
        end
      end
      if vault then
        require("obsidian").setup({
          workspaces = { { name = "notes", path = vault } },
        })
      end
    end,
  },
}
