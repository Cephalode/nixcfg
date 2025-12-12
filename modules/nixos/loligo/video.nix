{ config, pkgs, lib, ... }: {
  services.xserver.videoDrivers = [
    "modesetting"
	"nvidia"
  ];

  hardware = {
	nvidia = {
  	  modesetting.enable = true;

	  powerManagement = {
	    enable = false;
	    finegrained = true;
	  };
  
	  open = false;
  
	  nvidiaSettings = true;
	  package = config.boot.kernelPackages.nvidiaPackages.stable;
  
	  prime = {
	    offload = {
		  enable = true;
		  enableOffloadCmd = true;
	    };
	    intelBusId = "PCI:0:2:0";
	    nvidiaBusId = "PCI:1:0:0";
	  };
	};
  };
}
