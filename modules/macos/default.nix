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
    # ./kanata.nix  # retired on metasepia: Karabiner-Elements is the remapper here
    # (kanata's macOS backend needs Karabiner's root-only vhid socket AND an
    # exclusive keyboard grab, which Karabiner's engine also holds). Esc→`
    # added to configs/karabiner.json; rcmd+hjkl→arrows keeps working there too.
    ./syncthing.nix
    ./zen-omni-relay.nix
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
