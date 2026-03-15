{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sbctl # used to create keys
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
