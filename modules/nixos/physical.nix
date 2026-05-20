{
  config,
  pkgs,
  ...
}:
{
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };

  services = {
    blueman.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
  };
}
