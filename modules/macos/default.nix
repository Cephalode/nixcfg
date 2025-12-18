{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ./homebrew.nix
    ./packages.nix
  ];
}