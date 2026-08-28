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
    upower = {
      enable = true;
      # upower's compiled default critical-battery action is HybridSleep, which
      # fails on nvidia PM (nv_pmops_freeze returns -5) and leaves the machine
      # running on a dying battery. Hibernate is the verified-working path.
      criticalPowerAction = "Hibernate";
    };
  };
}
