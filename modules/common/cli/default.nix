{ config, pkgs, inputs, ... }:
{
  imports = [
    ./atuin
    ./btop
    ./cava
    ./fuzzel
    ./git
    ./kitty
    ./starship
  ];
}
