{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    # enableRosetta = true;
    user = "sqibo";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    taps = [
    ];
    brews = [
      "mas" # mac appstore cli
      "sox" # reroute audio
      "bob" # neovim version manager (using it to access vim.pack in v0.12 nightly)
      "nvm" # node version manager
    ];
    casks = [
      "bambu-studio"
      "beeper" # the nix package does not support aarch64
      "discord"
      "ghostty"
      "karabiner-elements"
      "obs"
      "obsidian"
      "raycast"
      "mactex"
    ];
    masApps = { # Mac Appstore apps
    };

    onActivation = {
      autoUpdate = true;
      # cleanup = "zap"; # Has issues with aerospace
      upgrade = true;
    };
    global = {
      brewfile = true;
    };
  };
}

