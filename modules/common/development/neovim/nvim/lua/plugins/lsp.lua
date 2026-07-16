return {
  -- Base lspconfig spec: shared on_attach + the lzextras lsp handler
  {
    "nvim-lspconfig",
    auto_enable = true,
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config("*", {
        on_attach = function(_, bufnr)
          local nmap = function(keys, func, desc)
            if desc then desc = "LSP: " .. desc end
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
          end
          nmap("gd", vim.lsp.buf.definition, "Goto definition")
          nmap("gr", vim.lsp.buf.references, "Goto references")
          nmap("gI", vim.lsp.buf.implementation, "Goto implementation")
          nmap("K", vim.lsp.buf.hover, "Hover documentation")
          nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
          nmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
          nmap("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
          nmap("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
          nmap("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })
    end,
  },
  -- Per-server specs, gated by for_cat
  {
    "lua_ls",
    for_cat = "lang.lua",
    lsp = {
      filetypes = { "lua" },
      settings = {
        Lua = {
          signatureHelp = { enabled = true },
          diagnostics = { globals = { "nixInfo", "vim" }, disable = { "missing-fields" } },
        },
      },
    },
  },
  {
    "nixd",
    for_cat = "lang.nix",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          formatting = { command = { "nixfmt" } },
          diagnostic = { suppress = { "sema-escaping-with" } },
        },
      },
    },
  },
  {
    "marksman",
    for_cat = "lang.markdown",
    lsp = { filetypes = { "markdown" } },
  },
  {
    "ts_ls",
    for_cat = "lang.ts",
    lsp = { filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
  },
  {
    "basedpyright",
    for_cat = "lang.python",
    lsp = { filetypes = { "python" } },
  },
  {
    "rust_analyzer",
    for_cat = "lang.rust",
    lsp = { filetypes = { "rust" } },
  },
  {
    "gopls",
    for_cat = "lang.go",
    lsp = { filetypes = { "go", "gomod", "gowork" } },
  },
  {
    "zls",
    for_cat = "lang.zig",
    lsp = { filetypes = { "zig" } },
  },
  {
    "clangd",
    for_cat = "lang.c",
    lsp = { filetypes = { "c", "cpp" } },
  },
}
