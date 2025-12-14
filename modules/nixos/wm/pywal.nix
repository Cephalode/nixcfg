{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pywal16
  ];

  programs.niri.enable = true;
}
