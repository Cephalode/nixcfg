{
  inputs,
  pkgs,
  ...
}:
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
