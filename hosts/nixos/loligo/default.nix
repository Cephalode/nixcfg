{ config, pkgs, inputs, outputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../.
  ];

  networking.hostName = "loligo";

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  system.stateVersion = "25.05"; # Do not change
}
