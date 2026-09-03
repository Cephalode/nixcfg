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
    ./powerbtn.nix
  ];

  networking.hostName = "hapalo";
  system.stateVersion = "25.05"; # Do not change

  # Zen twilight profile — synced via syncthing (modules/common/syncthing.nix)
  cephalode.zenProfilePath = "/home/sqibo/.zen/0vkp3u7b.Default Profile";

  # Power button: owned by powerbtn.nix daemon (short press = sw, hold = poweroff).
  # logind must ignore the key globally — its only sources here are the ACPI buttons.
  services.logind.powerKey = "ignore";

  environment.systemPackages = with pkgs; [
    google-chrome
    inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.grok-build.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Hibernate-swap to Windows (also the power button's short-press action).
    # Arms BootNext 0000 + an RTC wakealarm, then hibernates: the RTC fires the
    # box back on and firmware consumes BootNext -> boots Windows. Without the
    # wakealarm nothing powers the box back on until someone presses the button.
    (writeShellScriptBin "sw" ''
      set -euo pipefail

      # efivarfs and wakealarm writes need root; route through the NOPASSWD
      # systemd-run bridge (plain `sudo tee` is NOT covered by the rules)
      sudo -n /run/current-system/sw/bin/systemd-run --wait --pipe --quiet ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0000
      # RTC wake ~150s out: enough margin for the hibernate image write.
      # Compute the epoch in sw (transient units have a minimal PATH — no date)
      # and pass a literal to the root shell.
      alarm=$(( $(date +%s) + 150 ))
      sudo -n /run/current-system/sw/bin/systemd-run --wait --pipe --quiet ${pkgs.bash}/bin/bash -c "echo $alarm > /sys/class/rtc/rtc0/wakealarm"
      ${pkgs.systemd}/bin/systemctl hibernate
    '')
  ];

  boot.loader.limine = {
    secureBoot.enable = true;
    maxGenerations = 3;
    extraEntries = ''
      /Windows
        protocol: efi
        path: boot():/EFI/Microsoft/Boot/bootmgfw.efi 
    '';
  };

  boot.kernelParams = [
    "resume=UUID=b260e841-ed40-4868-82a2-b2ea8f0e896f"
    "resume_offset=43235328"
  ];

  hardware.customNvidia = {
    open = false;
  };
}
