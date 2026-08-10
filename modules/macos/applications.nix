{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
    duti
    karabiner-elements
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
    ];
    masApps = {
    };
  };
}
