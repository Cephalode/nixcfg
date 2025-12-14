{ config, pkgs, ... }: {
  imports = [
    ../common
    ./kb.nix
    ./audio.nix
    ./wm
  ];
}
