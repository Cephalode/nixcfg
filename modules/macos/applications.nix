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
      "lume"
      "nvm" # node version manager
    ];
    casks = [
      "bambu-studio"
      "beeper" # the nix package does not support aarch64
      "mactex-no-gui"
      "obsidian"
    ];
    masApps = {
      # Mac Appstore apps
    };
  };
}
