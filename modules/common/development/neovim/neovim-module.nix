inputs:
{ config, wlib, lib, pkgs, ... }:
{
  imports = [ wlib.wrapperModules.neovim ];

  # Use ~/.config/nvim as the config directory
  # Use relative path since this module is in ~/devel/nix/... and config is in ~/.config/nvim
  config.settings.config_directory = ../../../../../../.config/nvim;

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

  # Info values accessible from Lua
  config.info.testvalue = {
    some = "stuff";
    goes = "here";
  };

  # Lze lazy loader (using pkgs version)
  config.specs.lze = [
    {
      data = pkgs.vimPlugins.lze;
    }
    {
      data = pkgs.vimPlugins.lzextras;
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

  # Spec mods for extra packages support
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

  # Enabled specs info
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
}
