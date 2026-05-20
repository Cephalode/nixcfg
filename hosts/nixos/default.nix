{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = [
    ../common
  ];

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  users.users = {
    sqibo = {
      isNormalUser = true;
      description = "Main user.";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "seat"
      ];
    };
  };
}
