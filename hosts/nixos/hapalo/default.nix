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

  boot.loader.limine = {
    secureBoot.enable = true;
    maxGenerations = 3;
    extraEntries = ''
      /Windows
        protocol: efi
        path: boot():/EFI/Microsoft/Boot/bootmgfw.efi 
    '';
  };

  hardware.kanata.devices = [
    "/dev/input/by-path/pci-0000:0a:00.3-usb-0:3.3:1.0-event-kbd"
    "/dev/input/by-path/pci-0000:0a:00.3-usb-0:3.3:1.2-event-kbd"
  ];

  hardware.customNvidia = {
    open = false;
  };
}
