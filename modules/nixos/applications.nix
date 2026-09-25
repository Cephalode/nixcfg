{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    teams-for-linux
    t3code
    wl-clipboard # wl-copy / wl-paste
  ];
}
