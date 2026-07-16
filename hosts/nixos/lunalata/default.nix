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

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "25.05";
}
