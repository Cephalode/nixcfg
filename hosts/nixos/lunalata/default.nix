{ config, pkgs, inputs, outputs, lib, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../.
    ../../common
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "sqibo";
    startMenuLaunchers = true;
    wslConf = {
      network.hostname = "lunalata";
      interop.enabled = true;
    };
  };

  networking.hostName = "lunalata";

  # Zen twilight profile — synced via syncthing (modules/nixos/syncthing.nix).
  # Path is seeded (profiles.ini adopts it on first launch) so the synced
  # folder matches hapalo's dir name.
  cephalode.zenProfilePath = "/home/sqibo/.zen/0vkp3u7b.Default Profile";

  system.stateVersion = "25.05";
}
