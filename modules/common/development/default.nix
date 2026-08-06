{ config, pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./tmux.nix
    ./neovim
  ];
}
