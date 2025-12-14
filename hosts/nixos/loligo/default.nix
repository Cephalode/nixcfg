{ config, pkgs, inputs, outputs, lib, ... }: {
  imports = [
	./hardware-configuration.nix
    ../.
	../../../modules/nixos/loligo
  ];
  
  networking.hostName = "loligo";

  services.xserver.videoDrivers = [
    "modesetting"
	"nvidia"
  ];

  environment.systemPackages = with pkgs; [
  ];
  
  system.stateVersion = "25.05"; # Do not change
}
