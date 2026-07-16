{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
  homebrew.brews = [
    "lume"
  ];
}
