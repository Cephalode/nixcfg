{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    efibootmgr
    sbctl # used to create keys
    (writeShellScriptBin "reboot-windows" ''
      set -euo pipefail

      ${efibootmgr}/bin/efibootmgr --bootnext 0000
      ${systemd}/bin/systemctl reboot
    '')
  ];

  
  boot.loader = {
    efi.canTouchEfiVariables = true;

    limine = {
      enable = true;
      secureBoot.enable = true;
      extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi 
      '';
    };
  };
}
