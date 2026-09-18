{ pkgs, lib, config, inputs, ... }:
{
  # Linux-only. The nix kitty wrapper breaks its code signature, which on
  # macOS empties the Accessibility tree -> invisible to tiling WMs (OmniWM).
  # On macOS, kitty is the Homebrew cask (modules/macos/applications.nix);
  # it reads the same flake-managed ~/.config/kitty/kitty.conf symlinks.
  config = lib.mkIf pkgs.stdenv.isLinux {
    environment.systemPackages = [
      (inputs.wrappers.lib.evalPackage [
        ./module.nix
        { inherit pkgs; }
      ])
    ];
  };
}
