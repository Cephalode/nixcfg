{
  config,
  pkgs,
  lib,
  ...
}:
{

  boot.kernelModules = [ "uninput" ];

  hardware.uinput.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  users.groups.uinput = { };

  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
    ProtectHome = lib.mkForce "tmpfs";
    BindReadOnlyPaths = "/home/sqibo/.config/kanata/main.kdb";
  };
}
