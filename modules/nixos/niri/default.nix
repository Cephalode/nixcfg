{ pkgs, lib, config, inputs, ... }:
let
  niriWrapped = inputs.wrappers.lib.evalPackage [
    ./module.nix
    { inherit pkgs; }
  ];
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    environment.systemPackages = [ niriWrapped ];

    # greetd launches niri-session, whose niri.service ExecStarts the STORE binary
    # directly — bypassing the wrapper (and its NIRI_CONFIG). Point the unit at the
    # wrapped niri so modules/nixos/niri/config.kdl actually applies in sessions.
    systemd.user.services.niri = lib.mkIf config.programs.niri.enable {
      serviceConfig.ExecStart = lib.mkForce "${niriWrapped}/bin/niri --session";
    };
  };
}
