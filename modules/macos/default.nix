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
    })
  ];

  imports = [
    ../common
    ./devices.nix
    ./dotfiles.nix
    ./homebrew.nix
    ./applications.nix
    ./services.nix
    ./ai.nix
    ./kanata.nix
  ];

  security.sudo.extraConfig = ''
    sqibo ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

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
