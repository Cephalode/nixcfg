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

  networking.hostName = "hapalo";
  system.stateVersion = "25.05"; # Do not change

  hardware.kanata.devices = [
    "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.2:1.0-event-kbd"
    "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.3:1.1-event-kbd"
  ];

  hardware.customNvidia = {
    open = false;
  };
}
