{ config, pkgs, inputs, ... }:
{
  imports = [
    ./btop
    ./git
    ./kitty
    ./starship
  ];
}
