{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
  homebrew.brews = [
    "lume"
  ];
  # xurl ships in xdevplatform/tap as a CASK (no Formula dir) — not in nixpkgs
  homebrew.casks = [
    "xdevplatform/tap/xurl"
  ];
  homebrew.taps = [
    { name = "xdevplatform/tap"; trusted = true; }
  ];
}
