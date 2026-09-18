{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    duti
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
