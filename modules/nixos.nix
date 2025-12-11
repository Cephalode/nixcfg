{ config, pkgs, lib, inputs, ... }: {
  imports = [ 
    ./.
	./devices
	./devices/audio/nixos-audio.nix
	./rice
	./rice/window-manager/niri.nix
  ];
}
