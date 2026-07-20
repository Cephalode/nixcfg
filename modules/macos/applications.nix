{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
    karabiner-elements
    mas
    mkalias
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
