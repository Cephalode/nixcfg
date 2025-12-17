{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    aerospace
    raycast
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
  ];

  homebrew = {
    enable = true;
    taps = [
    ];
    brews = [
      "mas" # mac appstore cli
      "sox" # reroute audio
      "nvm" # node version manager
    ];
    casks = [
      "bambu-studio"
      "beeper" # the nix package does not support aarch64
      "karabiner-elements"
      "mactex"
    ];
    masApps = { # Mac Appstore apps
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Has issues with aerospace
      upgrade = true;
    };
    global = {
      brewfile = true;
    };
  };
}
