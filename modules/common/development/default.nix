{ config, pkgs, ... }:
{
  imports = [
    ./neovim
    ./cli.nix
    ./languages.nix
    ./tmux.nix
    ./work.nix
  ];
}
