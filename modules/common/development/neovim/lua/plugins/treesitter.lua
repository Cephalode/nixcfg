-- TODO (no clue what I am doing)
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { '' },
-- })
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexp()"
