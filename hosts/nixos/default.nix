{ config, pkgs, inputs, outputs, lib, ...}: {
  imports = [
    ../common
	../../modules/nixos.nix
  ];

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth = {
    enable = true;
	powerOnBoot = true;
  };

  environment.systemPackages = with pkgs; [
    git
	firefox
  ];

  services = {
    openssh.enable = true;
  };

  nix.settings.trusted-users = [ "root" "sqibo" ];

  system.stateVersion = "25.05"; # Do not change
}
