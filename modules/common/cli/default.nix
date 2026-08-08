{ config, pkgs, inputs, ... }:
{
  imports = [
    ./atuin
    ./btop
    ./fuzzel
    ./git
    ./kitty
    ./starship
  ];
}
