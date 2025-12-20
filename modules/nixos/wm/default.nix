{ config, pkgs, ... }: {
  imports = [
    ./niri.nix
    ./noctalia.nix
    ./pywal.nix
  ];
}
