require "config.options"
require "config.keymap"
require "config.autocmd"

-- TODO handling the configuration without nixCats
-- require("lze").register_handlers(require('nixCatsUtils.lzUtils').for_cat)

-- To make LSPs compatible with the lze spec
require('lze').resister_handlers(require('lzextras').lsp)

require "config.plugins"
require "config.lsp"


-- TODO
-- if nixCats('debug') then
--   require "config.debug"
-- end
-- 
-- if nixCats('lint') then
--   require "config.lint"
-- end
-- 
-- if nixCats('format') then
--   require "config.format"
-- end
