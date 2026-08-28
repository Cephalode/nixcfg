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
    # directly — bypassing the wrapper (and its NIRI_CONFIG). niri.service is a
    # package-shipped unit, so a drop-in ExecStart ACCUMULATES ("more than one
    # ExecStart=" → unit refused). The leading "" emits a bare `ExecStart=` that
    # resets the list before adding ours — canonical idiom for overriding
    # ExecStart of a foreign unit.
    systemd.user.services.niri = lib.mkIf config.programs.niri.enable {
      serviceConfig.ExecStart = lib.mkForce [ "" "${niriWrapped}/bin/niri --session" ];
    };
  };
}
