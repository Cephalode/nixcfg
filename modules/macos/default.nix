{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      notesmd-cli = final.callPackage ../../pkgs/notesmd-cli { };
      # ponytail: kitty 0.47.4 linker crash (cctools ld SIGTRAP) on aarch64-darwin;
      # use stable 0.44.0 which builds fine. Homebrew cask kitty is the real binary.
      kitty = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.kitty;
    })
  ];

  imports = [
    ../common
    ./devices.nix
    ./dotfiles.nix
    ./homebrew.nix
    ./applications.nix
    ./services.nix
    ./sudo-rebuild.nix
    ./ai.nix
    ./kanata.nix
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # Disable default prompt
    };
  };

  system.activationScripts.setBrowser.text = ''
    sudo -u sqibo ${pkgs.duti}/bin/duti -s app.zen-browser.zen http
    sudo -u sqibo ${pkgs.duti}/bin/duti -s app.zen-browser.zen https
    sudo -u sqibo ${pkgs.duti}/bin/duti -s app.zen-browser.zen .html
  '';
}
