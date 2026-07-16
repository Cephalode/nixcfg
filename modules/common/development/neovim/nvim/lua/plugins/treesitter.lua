return {
  {
    "nvim-treesitter",
    auto_enable = true,
    lazy = false,
    after = function()
      local function try_attach(buf, language)
        if not vim.treesitter.language.add(language) then return false end
        vim.treesitter.start(buf, language)
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        vim.o.foldlevel = 99
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        return true
      end

      local installable = require("nvim-treesitter").get_available()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buf, ft = args.buf, args.match
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then return end
          if not try_attach(buf, lang) then
            if vim.tbl_contains(installable, lang) then
              require("nvim-treesitter").install(lang):await(function()
                try_attach(buf, lang)
              end)
            end
          end
        end,
      })
    end,
  },
}
