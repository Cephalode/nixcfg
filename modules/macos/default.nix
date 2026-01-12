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
  ];
}
