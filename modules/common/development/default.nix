{ config, pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./languages.nix
  ];

  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}
