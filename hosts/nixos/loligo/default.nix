{ config, pkgs, inputs, outputs, lib, ... }: {
  imports = [
    ../default.nix
	./hardware-configuration.nix
  ];
}
