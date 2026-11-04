{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  # t3code CLI from the fresh input (stable channel). The background service is
  # NOT managed here: `t3 service install` owns ~/Library/LaunchAgents/
  # com.t3tools.t3code.service.plist and `t3 update` keeps the runtime
  # current (0.1.6+, required by the iOS client 2.2.0). A nix-pinned agent
  # with the same label races t3's own KeepAlive service at every login —
  # removed 2026-11-03, do not re-add.
  t3-stable = inputs.nixpkgs-fresh.legacyPackages.${pkgs.system}.t3code;
in
{
  environment.systemPackages = with pkgs; [
    duti
    kitty.terminfo # ssh sessions from kitty (TERM=xterm-kitty) need the entry; cask ships it inside the .app only
    mas
    mkalias
    notesmd-cli
    obsidian
    raycast
    sox
    t3-stable
  ];
  homebrew = {
    taps = [
    ];
    brews = [
    ];
    casks = [
      "anki"
      "beeper"
      "kitty"
      "omniwm"
    ];
    masApps = {
    };
  };
}
