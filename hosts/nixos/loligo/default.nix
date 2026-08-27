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

  networking.hostName = "loligo";

  # Hibernate: resume from the swap partition (nvme0n1p3)
  boot.kernelParams = [ "resume=UUID=62569a8c-85a6-4eb0-80fd-5297dbabe399" ];

  hardware.customNvidia = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  system.stateVersion = "25.05"; # Do not change
}
