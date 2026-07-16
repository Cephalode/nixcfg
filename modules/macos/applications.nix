{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
    anki
    karabiner-elements
    mas
    mkalias
    obsidian
    raycast
    sox
    sunshine
  ];
  homebrew = {
    taps = [
    ];
    brews = [
    ];
    casks = [
      "beeper"
    ];
    masApps = {
    };
  };
}
