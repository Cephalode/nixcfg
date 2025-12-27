{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.xserver.videoDrivers = [
    "nvidia"
    "modesetting"
  ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = lib.mkDefault true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime =
      lib.mkIf config.networking.hostName == "loligo" {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
  };
}
