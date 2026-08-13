{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    efibootmgr
    sbctl # used to create keys
    (writeShellScriptBin "sw" ''
      set -euo pipefail

      ${efibootmgr}/bin/efibootmgr --bootnext 0000
      ${systemd}/bin/systemctl hibernate
    '')
  ];

  
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine.enable = true;
  };
}
