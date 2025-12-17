{ config, pkgs, lib, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = lib.mkDefault true;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];

  # Optional: if you use Wayland and see weirdness, this usually helps:
  # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}
