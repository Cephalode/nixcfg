{ config, pkgs, ... }:
{
  imports = [
    ./editor
    ./cli.nix
    ./languages.nix
  ];

  environment.systemPackages = with pkgs; [
    code-cursor
  ];
}
