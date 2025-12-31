{ config, pkgs, ... }:
{
  imports = [
    ./neovim
    ./cli.nix
    ./languages.nix
    ./tmux.nix
  ];

  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}
