{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    efibootmgr
    sbctl # used to create keys
    (writeShellScriptBin "sw" ''
      set -euo pipefail

      # efivarfs writes need root; route through the NOPASSWD systemd-run bridge
      sudo -n /run/current-system/sw/bin/systemd-run --wait --pipe --quiet ${efibootmgr}/bin/efibootmgr --bootnext 0000
      ${systemd}/bin/systemctl hibernate
    '')
  ];

  
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine.enable = true;
  };
}
