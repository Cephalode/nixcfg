{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../common
    ./devices.nix
    ./homebrew.nix
    ./applications.nix
    ./services.nix
    ./ai.nix
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # Disable default prompt
    };
  };
}
