{ config, pkgs, ... }: {
  imports = [
    ../common
    ./niri.nix
	./kb.nix
	./audio.nix
  ];
}
