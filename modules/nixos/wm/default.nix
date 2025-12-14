{ config, pkgs, ... }: {
  imports = [
    ./niri.nix
    ./pywal.nix
  ];
}
