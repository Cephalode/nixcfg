local catUtils = require('nixCatsUtils')
if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end

local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
require('lze').h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    if not ok then
      ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
    end
    return (ok and cfg or {}).filetypes or {}
  else
    return old_ft_fallback(name)
  end
end)
require('lze').load {
  {
    "nvim-lspconfig",
    for_cat = "general.always",
    on_require = { "lspconfig" },
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = require "config.lsp.on_attach",
      })
    end,
  },
  {
    "mason.nvim",
    enabled = not catUtils.isNixCats,
    on_plugin = { "nvim-lspconfig" },
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("mason-lspconfig.nvim")
      require('mason').setup()
      require('mason-lspconfig').setup { automatic_installation = true, }
    end,
  },
  {
    "lazydev.nvim",
    for_cat = "neonixdev",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function()
      require('lazydev').setup({
        library = {
          {
            words = { "nixCats" },
            path = (nixCats.nixCatsPath or "") .. '/lua'
          },
        },
      })
    end,
  },
  {
    "lua_ls",
    enabled = nixCats('lua') or nixCats('neonixdev') or false,
    lsp = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = { ignoreComments = true },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { "nixCats", "vim" },
            disable = { "missing-fields" },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    "rnix",
    enable = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nil_ls",
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nixd",
    enabled = catUtils.isNixCats and (nixCats('nix') or nixCats('neonixdev')) or false,
    lsp {
      filetypes = { "nix" },
      settings = {
        nixd = {
          nixpkgs = {
            expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
          },
          options = {
            nixos = {
              expr = nixCats.extra("nixdExtras.nixos_options")
            },
            nix-darwin = {
              expr = nixCats.extra("nixdExtras.nix_darwin_option")
            },
          },
          formatting = {
            command = { "nixfmt" }
          },
          diagnostic = {
            supress = {
              "sema-escaping-with"
            },
          },
        },
      },
    },
  },
  {
    "marksman",
    lsp = {
      filetypes = { 'markdown', 'markdown.mdx' },
      cmd = { "marksman", "server" },
      root_markers = { ".marksman.toml", ".git" },
    },
  },
}
