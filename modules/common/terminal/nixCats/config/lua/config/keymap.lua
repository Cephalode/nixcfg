local map = vim.keymap.set                 -- shorten mapping command
map('n', '<leader>lf', vim.lsp.buf.format) -- autoformat

map('n', '<leader>f', ":Pick files<CR>")   -- File tree picker
map('n', '<leader>h', ":Pick help<CR>")    -- Help manuals
map('n', '<leader>e', ":Oil<CR>")          -- File explorer
map('n', '<leader>s', ":e #<CR>")          -- Open last file
map('n', '<leader>S', ":sf #<CR>")         -- Open last file horizontally

map('n', '<leader>o', ':update<CR>: source<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>') -- copy to clipboard
