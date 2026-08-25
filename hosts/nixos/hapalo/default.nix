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

  networking.hostName = "hapalo";
  system.stateVersion = "25.05"; # Do not change

  environment.systemPackages = with pkgs; [
    google-chrome
    inputs.bedrock-on-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.grok-build.packages.${pkgs.stdenv.hostPlatform.system}.default
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
