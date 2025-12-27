{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.nvf.nixosModules.default ];

  environment.systemPackages = with pkgs; [
    inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Language servers
    python313Packages.pylsp-mypy
    lua-language-server
    typescript-language-server
    nil # Nix language server
  ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      viAlias = false;
      vimAlias = true;

      lsp = {
        enable = true;
        formatOnSave = true;
      };
    };
  };
}
