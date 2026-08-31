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

  # Zen twilight profile — synced via syncthing (modules/common/syncthing.nix)
  cephalode.zenProfilePath = "/home/sqibo/.zen/7r0v1cgu.Default Profile";

  # Hibernate: resume from the swap partition (nvme0n1p3)
  boot.kernelParams = [ "resume=UUID=62569a8c-85a6-4eb0-80fd-5297dbabe399" ];

  # Lid close: hibernate immediately (resume from the swap partition —
  # verified working; no RTC timer involved).
  # Power button short-press: suspend. Long-press stays ignore (spare binding).
  services.logind = {
    lidSwitch = "hibernate";
    powerKey = "suspend";
  };

  # Battery: cap charge at 80% (Latitude EC honors these; start stays at the
  # firmware default 50). Root-only sysfs write, re-applied at each boot.
  systemd.tmpfiles.rules = [
    "w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80"
  ];

  # Timing for the noctalia "Sleep" panel entry (suspend-then-hibernate):
  # RTC check every 30s, hibernate once the battery estimate is under 45m.
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = 30;
    HibernateThresholdSec = 45;
  };

  hardware.customNvidia = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  system.stateVersion = "25.05"; # Do not change
}
