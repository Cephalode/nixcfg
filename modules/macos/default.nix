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
    ./homebrew.nix
    ./applications.nix
  ];
}
