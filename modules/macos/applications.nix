{
  config,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    aerospace
    karabiner-elements
    mas
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
    raycast
    sox
  ];
  homebrew = {
    taps = [
    ];
    brews = [
      "nvm" # node version manager
    ];
    casks = [
      "bambu-studio"
      "beeper" # the nix package does not support aarch64
      "obsidian"
      "mactex"
    ];
    masApps = {
      # Mac Appstore apps
    };
  };
}
