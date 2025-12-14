{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./terminal
    ./applications.nix
  ];
}
