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

