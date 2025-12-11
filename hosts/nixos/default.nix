{ config, pkgs, inputs, outputs, lib, ...}: {
  imports = [
    ../common
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)

  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users = {
    sqibo = {
      isNormalUser = true;
      description = "sqibo";
      extraGroups = [ "wheel" "networkmanager" "audio" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = with pkgs; [
      firefox
      fuzzel
      git
      waybar
      wl-clipboard
    ];

    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
  };

  services = {
    openssh.enable = true;
  };

  nix.settings.trusted-users = [ "root" "sqibo" ];

  system.stateVersion = "25.05";
}
