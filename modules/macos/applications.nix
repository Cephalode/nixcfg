{ config, pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true; # Allow closed source software

  # Packages from Nix
  environment.systemPackages = with pkgs; [
    aerospace
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
    neovim
  ];

  homebrew = {
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
      "karabiner-elements"
      "obs"
      "obsidian"
      "raycast"
      "mactex"
    ];
    masApps = { # Mac Appstore apps
    };
  };
}