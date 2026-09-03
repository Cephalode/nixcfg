{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    efibootmgr
    sbctl # used to create keys
  ];

  
  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine.enable = true;
  };
}
