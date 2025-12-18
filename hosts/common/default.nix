# Common configuration for all hosts

{ lib, inputs, outputs, ... }: {
  imports = [ ../../modules/common ];

  nix.settings = {
    trusted-users = [ "root" "sqibo" ];
    experimental-features = [ "nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;

  # Make `pkgs.neovim` come from the nightly overlay across all hosts.
  nixpkgs.overlays =
    let
      nvimOverlay =
        if inputs.neovim-nightly-overlay ? overlays && inputs.neovim-nightly-overlay.overlays ? default
        then inputs.neovim-nightly-overlay.overlays.default
        else inputs.neovim-nightly-overlay.overlay;
    in
    [ nvimOverlay ];
}
