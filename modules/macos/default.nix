{ config, pkgs, ... }: {
  imports = [
    ./applications.nix
    ./homebrew.nix
  ];
}
