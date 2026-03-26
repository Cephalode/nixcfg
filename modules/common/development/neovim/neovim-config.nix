inputs:
{ wlib, config, pkgs, lib, ... }:
{
  imports = [ wlib.wrapperModules.neovim ];

  # Use stdpath('config') to reference ~/.config/nvim
  config.settings.config_directory = lib.generators.mkLuaInline "vim.fn.stdpath('config')";

  # Create the nvim-lib option with pluginsFromPrefix
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default =
      builtins.listToAttrs (
        builtins.map
          (
            name: {
              inherit name;
              value = let
                cleanName = builtins.removePrefix "neovim-plugins-" name;
              in
                inputs.nix-wrapper-modules.lib.mkPlugin cleanName inputs.${name};
            }
          )
          (builtins.filter (builtins.hasPrefix "neovim-plugins-") (builtins.attrNames inputs))
      );
  };

  # Colorscheme option
  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "onedark_dark";
  };
  config.settings.colorscheme = "moonfly";
  config.specs.colorscheme = {
    lazy = true;
    data = with pkgs.vimPlugins; {
      "onedark_dark" = onedarkpro-nvim;
      "onedark_vivid" = onedarkpro-nvim;
      "onedark" = onedarkpro-nvim;
      "onelight" = onedarkpro-nvim;
      "moonfly" = vim-moonfly-colors;
    }.${config.settings.colorscheme};
  };

  # Info values
  config.info.testvalue = {
    some = "stuff";
    goes = "here";
  };

  # Lze specs
  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  # Nix tools
  config.specs.nix = {
    data = null;
    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];
  };

  # Lua tools
  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  # General plugins
  config.specs.general = {
    after = [ "lze" ];
    lazy = true;
    extraPackages = with pkgs; [
      lazygit
      tree-sitter
    ];
    data = with pkgs.vimPlugins; [
      {
        data = vim-sleuth;
        lazy = false;
      }
      snacks-nvim
      nvim-lspconfig
      nvim-surround
      vim-startuptime
      blink-cmp
      blink-compat
      cmp-cmdline
      colorful-menu-nvim
      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      nvim-lint
      conform-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
    ];
  };

  # Spec mods
  config.specMods =
    { parentSpec ? null, parentOpts ? null, parentName ? null, config, ... }:
    {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
        description = "Extra packages to add to PATH";
      };
    };
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  # Enabled specs
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
}
