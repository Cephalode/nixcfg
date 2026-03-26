{ config, pkgs, ... }:
{
  imports = [
    ./neovim
    ./agents.nix
    ./cli.nix
    ./languages.nix
    ./tmux.nix
    ./work.nix
  ];
}
