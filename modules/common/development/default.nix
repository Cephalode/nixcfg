{ config, pkgs, ... }:
{
  imports = [
    ./agents.nix
    ./cli.nix
    ./languages.nix
    ./tmux.nix
    ./neovim
    ./work.nix
  ];
}
