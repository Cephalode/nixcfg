{
  config,
  lib,
  ...
}:

let
  cfg = config.hardware.customNvidia;
in
{
  options.hardware.customNvidia = {
    intelBusId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Intel GPU PCI bus ID for PRIME offload (e.g. \"PCI:0:2:0\").";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Nvidia GPU PCI bus ID for PRIME offload (e.g. \"PCI:1:0:0\").";
    };

    open = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the open-source Nvidia kernel module.";
    };
  };

  config = {
    services.xserver.videoDrivers = [
      "nvidia"
      "modesetting"
    ];

    hardware.nvidia = {
      open = cfg.open;
      modesetting.enable = true;
      powerManagement.enable = lib.mkDefault true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime =
        lib.mkIf (cfg.intelBusId != null) {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          intelBusId = cfg.intelBusId;
          nvidiaBusId = cfg.nvidiaBusId;
        };
    };
  };
}
