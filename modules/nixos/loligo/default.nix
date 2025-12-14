{ config, pkgs, lib, ... }: {
	imports = [
		../.
		./video.nix
	];
}
