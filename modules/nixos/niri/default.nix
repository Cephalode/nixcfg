{ pkgs, lib, config, inputs, ... }:
let
  niriWrapped = inputs.wrappers.lib.evalPackage [
    ./module.nix
    { inherit pkgs; }
  ];
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    # wf-recorder + slurp: screen recording wired to niri Ctrl+Shift+R
    environment.systemPackages = [ niriWrapped pkgs.wf-recorder pkgs.slurp ];

    # greetd launches niri-session, whose niri.service ExecStarts the STORE binary
    # directly — bypassing the wrapper (and its NIRI_CONFIG). niri.service is a
    # package-shipped unit, so a drop-in ExecStart ACCUMULATES ("more than one
    # ExecStart=" → unit refused). The leading "" emits a bare `ExecStart=` that
    # resets the list before adding ours — canonical idiom for overriding
    # ExecStart of a foreign unit.
    systemd.user.services.niri = lib.mkIf config.programs.niri.enable {
      serviceConfig.ExecStart = lib.mkForce [ "" "${niriWrapped}/bin/niri --session" ];
    };

    # Clipboard history daemon — records wl-clipboard selections so the
    # cliphist+fuzzel picker (niri Ctrl+Shift+V = physical Cmd+Shift+V after
    # the kanata Ctrl<->Super swap) has history to list. Dies with the
    # graphical session (partOf), restarts on crash. History lives in
    # ~/.cache/cliphist, capped by cliphist's own max-items default.
    # NOTE: cliphist 0.7.0 REMOVED its `watch` subcommand — the storage side
    # is a wl-paste --watch pipeline now.
    systemd.user.services.cliphist = {
      description = "cliphist: Wayland clipboard history daemon";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
