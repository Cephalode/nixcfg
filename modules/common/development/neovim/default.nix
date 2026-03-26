{ config, pkgs, lib, inputs, ... }:
let
  # Use standard neovim with custom config
  # Note: nix-wrapper-modules integration attempts failed due to evaluation hanging
  # See ./NEOVIM_SETUP.md for details and future work
  neovimConfigured = pkgs.neovim.override {
    viAlias = true;
    vimAlias = true;
  };
in
{
  environment.systemPackages = [
    neovimConfigured
  ];

  # Set environment variables to use the wrapped neovim
  environment.variables = {
    EDITOR = lib.getExe neovimConfigured;
    MANPAGER = "${lib.getExe neovimConfigured} +Man!";
  };
}
