{ config, pkgs, inputs, ... }:

let
  # Stable wrapper: the real darwin-rebuild store path changes every rebuild,
  # the sudoers rule re-interpolates this script's path instead.
  rebuild = pkgs.writeShellScriptBin "darwin-rebuild-wrapper" ''
    exec ${inputs.nix-darwin.packages.${pkgs.stdenv.hostPlatform.system}.darwin-rebuild}/bin/darwin-rebuild "$@"
  '';
in
{
  security.sudo.extraConfig = ''
    sqibo ALL=(root) NOPASSWD: ${rebuild}/bin/darwin-rebuild-wrapper
  '';

  environment.systemPackages = [ rebuild ];
}
