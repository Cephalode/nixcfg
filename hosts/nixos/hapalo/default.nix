{ config, pkgs, inputs, outputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../.
  ];

  networking.hostName = "hapalo";

  system.stateVersion = "25.05"; # Do not change
}
