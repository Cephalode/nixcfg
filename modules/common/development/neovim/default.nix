{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.development.neovim;
  homePrefix = if pkgs.stdenv.isDarwin then "/Users/sqibo" else "/home/sqibo";
in
{
  options.development.neovim = {
    obsidianVault = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to Obsidian vault. null = auto-detect in Lua.";
    };
    impureConfig = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Load nvim config from repo checkout for instant reload.";
    };
  };

  config = {
    environment.systemPackages = [
      (inputs.wrappers.lib.evalPackage [
        ./module.nix
        { inherit pkgs; }
        ({ info.obsidian_vault = cfg.obsidianVault; }
          // (lib.optionalAttrs cfg.impureConfig {
            settings.config_directory = "${homePrefix}/devel/nix/modules/common/development/neovim/nvim";
          }))
      ])
    ];

    environment.variables = {
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
  };
}
