{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./homebrew.nix
    ./applications.nix
  ];
}