-- Plugins
vim.pack.add({
	{ src = "https://github.com/EdenEast/nightfox.nvim" },       -- theme
	{ src = "https://github.com/stevearc/oil.nvim" },            -- file explorer
	{ src = "https://github.com/echasnovski/mini.pick" },        -- pop-up selector
	{ src = "https://github.com/mason-org/mason.nvim" },         -- lsp manager
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" }, -- lsp manager
	{ src = "https://github.com/ThePrimeagen/vim-be-good" },     -- vim practice
})
require "mini.pick".setup()
require "oil".setup()

require "nvim-treesitter.configs".setup({
	ensure_installed = { "lua", "typescript", "javascript" },
	highlight = { enable = true },
})
require "mason".setup({
	ensure_installed = lsp_servers,
})

-- autocompletion
vim.cmd("set completeopt+=noselect")

-- colors
require('nightfox').setup({
	options = {
		transparent = true,
		terminal_colors = true,
		module_default = true,
	}
})
vim.cmd("colorscheme nightfox")
vim.cmd(":hi statusline guibg=NONE")
