{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
  homebrew.brews = [
    "lume"
    "xdevplatform/tap/xurl" # X/Twitter CLI — not in nixpkgs
  ];
  homebrew.taps = [
    { name = "xdevplatform/tap"; trusted = true; }
  ];
}
