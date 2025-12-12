{ config, pkgs, inputs, outputs, lib, ...}: {
  imports = [
    ../common
  ];

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth = {
    enable = true;
	powerOnBoot = true;
  };

  services = {
    openssh.enable = true;
  };
}
