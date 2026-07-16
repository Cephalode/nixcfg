{ config, wlib, lib, pkgs, options, ... }:
{
  imports = [ wlib.wrapperModules.neovim ];

  config.settings.config_directory = ./nvim;
  config.settings.aliases = [ "vi" "vim" ];

  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "habamax";
  };

  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  config.specs.core = with pkgs.vimPlugins; [ lze lzextras ];
  config.specs.treesitter.data = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  config.specs.oil = pkgs.vimPlugins.oil-nvim;
  config.specs.mini = pkgs.vimPlugins.mini-nvim;
  config.specs.obsidian = {
    lazy = true;
    data = pkgs.vimPlugins.obsidian-nvim;
  };
  config.specs.completion = {
    lazy = true;
    data = with pkgs.vimPlugins; [ blink-cmp friendly-snippets ];
  };
  config.specs.lsp.data = pkgs.vimPlugins.nvim-lspconfig;

  config.specs."lang.lua" = {
    lazy = true;
    data = pkgs.vimPlugins.lazydev-nvim;
  };
  config.specs."lang.nix" = { lazy = true; data = null; };
  config.specs."lang.markdown" = { lazy = true; data = null; };
  config.specs."lang.ts" = { lazy = true; data = null; };
  config.specs."lang.python" = { lazy = true; data = null; };
  config.specs."lang.rust" = { lazy = true; data = null; };
  config.specs."lang.go" = { lazy = true; data = null; };
  config.specs."lang.zig" = { lazy = true; data = null; };
  config.specs."lang.c" = { lazy = true; data = null; };

  config.specs.extras = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      conform-nvim
      nvim-lint
      gitsigns-nvim
      which-key-nvim
      nvim-surround
      todo-comments-nvim
      fidget-nvim
      undotree
    ];
  };

  # ponytail: all LSP/formatter/linter binaries on nvim's PATH
  config.runtimePkgs = with pkgs; [
    lua-language-server stylua
    nixd nixfmt
    marksman
    typescript-language-server biome
    basedpyright ruff
    rust-analyzer rustfmt
    gopls gofumpt
    zls
    clang-tools
  ];
}
