{ config, pkgs, inputs, outputs, lib, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../.
    ../../common
  ];

  wsl = {
    enable = true;
    defaultUser = "sqibo";
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf = {
      network.hostname = "lunalata";
      interop.enabled = true;
    };
  };

  networking.hostName = "lunalata";
  system.stateVersion = "25.05";
}
