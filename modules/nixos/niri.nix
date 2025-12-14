{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    fuzzel
    mako
    pywal16
    waybar
  ];

  programs.niri.enable = true;
}
