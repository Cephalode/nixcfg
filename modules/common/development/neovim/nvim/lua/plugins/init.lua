-- Collect specs from all plugin modules and load them
local all = {}
for _, mod in ipairs({
  "oil", "pick", "treesitter", "lsp", "completion",
  "format", "lint", "git", "obsidian", "ui",
}) do
  vim.list_extend(all, require("plugins." .. mod))
end
nixInfo.lze.load(all)
