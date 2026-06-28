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
      "beeper" # the nix package does not support aarch64
    ];
    masApps = {
      # Mac Appstore apps
      #Tailscale = 1475387142; # https://apps.apple.com/app/tailscale/id1475387142
    };
  };
}
