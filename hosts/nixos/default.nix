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
    ../common
  ];

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };

  services = {
    openssh.enable = true;
    blueman.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };

  users.users = {
    sqibo = {
      isNormalUser = true;
      description = "Main user.";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "seat"
      ];
    };
  };
}
