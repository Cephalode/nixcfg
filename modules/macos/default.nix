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
      # NOTE: no kitty override here. The nix kitty wrapper breaks its code
      # signature (empty AX tree -> invisible to OmniWM); macOS kitty is the
      # Homebrew cask in modules/macos/applications.nix. The nix wrapper is
      # Linux-only (modules/common/cli/default.nix).
    })
    (import ../../overlays/tcc-friendly-apps.nix)
  ];

  imports = [
    ../common
    ./devices.nix
    ./dotfiles.nix
    ./homebrew.nix
    ./applications.nix
    ./services.nix
    ./sudo-rebuild.nix
    ./tcc-apps.nix
    ./ai.nix
    ./kanata.nix  # kanata = the remapper; retires Karabiner's engine at each boot
    ./syncthing.nix
    # zen-omni-relay disabled 2026-09-19 (omni sync off on all machines).
    # Extensions renamed *.disabled-2026-09-18 in every Zen profile on
    # metasepia + loligo. Re-enable: restore import + rename dirs back.
    # ./zen-omni-relay.nix
  ];

  programs = {
    zsh = {
      enable = true;
      promptInit = ""; # Disable default prompt
    };
  };

  system.activationScripts.setBrowser.text = ''
    sudo -u cephalode ${pkgs.duti}/bin/duti -s app.zen-browser.zen http
    sudo -u cephalode ${pkgs.duti}/bin/duti -s app.zen-browser.zen https
    sudo -u cephalode ${pkgs.duti}/bin/duti -s app.zen-browser.zen .html
  '';
}
