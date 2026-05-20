{ config, pkgs, ... }:
{
  imports = [
    ./agents.nix
    ./cli.nix
    ./languages.nix
    ./tmux.nix
    ./work.nix
  ];
}
