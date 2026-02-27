{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../.
  ];

  boot.loader.limine.enable = true;

  networking.hostName = "hapalo";
  system.stateVersion = "25.05"; # Do not change
}
