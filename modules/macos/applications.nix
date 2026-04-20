{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
    karabiner-elements # Required for VirtualHIDKeyboard driver — kanata uses it for output on macOS
    mas
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
    raycast
    sox
  ];
  homebrew = {
    taps = [
    ];
    brews = [
      "nvm"
    ];
    casks = [
      "bambu-studio"
      "beeper" # the nix package does not support aarch64
      "mactex-no-gui"
      "obsidian"
      "teamspeak-client@beta"
    ];
    masApps = {
      # Mac Appstore apps
    };
  };
}
