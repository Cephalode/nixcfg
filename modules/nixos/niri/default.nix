{ pkgs, lib, config, inputs, ... }:
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    environment.systemPackages = [
      (inputs.wrappers.lib.evalPackage [
        ./module.nix
        { inherit pkgs; }
      ])
    ];

    # niri.service runs the unwrapped binary (no config env); it reads
    # ~/.config/niri/config.kdl — keep that path pointed at this config.
    systemd.user.tmpfiles.rules = [
      "L+ %h/.config/niri/config.kdl - - - - ${./config.kdl}"
    ];
  };
}
