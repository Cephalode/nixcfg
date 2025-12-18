

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

  nixpkgs.config.allowUnfree = true; # Allow closed source software
  nixpkgs.overlays =
    let
      nvimOverlay =
        if inputs.neovim-nightly-overlay ? overlays && inputs.neovim-nightly-overlay.overlays ? default
        then inputs.neovim-nightly-overlay.overlays.default
        else inputs.neovim-nightly-overlay.overlay;
    in
    [ nvimOverlay ];

  # Packages from Nix
  environment.systemPackages = with pkgs; [
    aerospace
    btop
    cursor-cli
    code-cursor
    fzf
    hub
    jq
    mkalias # Allows apps in /Applications/Nix to show up in Raycast
    neovim
    tmux
    tree-sitter # Neovim plugin
    uwufetch
    xdg-ninja # Checks home folder for unnecessary dotfiles
  ];

  # Packages from brew
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

  fonts.packages = [
  ];

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.00;
      orientation = "left";
      persistent-apps = [
      ];
      scroll-to-open = true; # Scroll on a dock app to show all windows
      show-recents = false;
    };

    finder = {
      FXPreferredViewStyle = "clmv";
      FXEnableExtensionChangeWarning = false;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    LaunchServices.LSQuarantine = false;
  };

  # Programs
  programs.zsh = {
    enable = true;
    variables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    };
  };

  # Enable flakes (still useful even when this file is just a module)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.primaryUser = "sqibo"; # Sets user
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; # Sets git hash
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin"; # Architecture
}
