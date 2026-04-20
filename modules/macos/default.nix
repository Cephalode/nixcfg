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
    ./dotfiles.nix
    ./homebrew.nix
    ./applications.nix
    ./services.nix
    ./ai.nix
    ./kanata.nix
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # Disable default prompt
    };
  };
}
