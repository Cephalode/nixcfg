-- options
--------------------------------------------------------------------------------
-- Relative and absolute line numbers combined
vim.opt.number = true
vim.opt.relativenumber = true

-- Move focus with cursor
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Cursorline
vim.opt.cursorline = true

-- Show whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false -- don't highlight search results
vim.opt.incsearch = true

-- Preview substitutions
vim.opt.inccommand = 'split'

-- Text wrapping
vim.opt.wrap = false
vim.opt.breakindent = true

-- Tabstops
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Save undo history
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true

-- Set the default border for all floating windows
vim.opt.winborder = 'rounded'
