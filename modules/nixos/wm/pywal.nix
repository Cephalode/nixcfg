{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pywal16
    imagemagick
  ];
}
