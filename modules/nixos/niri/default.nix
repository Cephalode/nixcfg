{ pkgs, lib, config, inputs, ... }:
let
  niriWrapped = inputs.wrappers.lib.evalPackage [
    ./module.nix
    { inherit pkgs; }
  ];

  # Video mode: snap the focused browser to a 16:9 window and center it.
  # True fullscreen always covers the whole 3440x1440 panel (black bars on a
  # 16:9 video), and niri has no is-fullscreen matcher to constrain it — so
  # video watching happens in a normal tiled window instead: 2048 logical px
  # = 2560 device px at scale 1.25. If the browser is true-fullscreen
  # (F11 / site fullscreen button), that is toggled off first: fullscreen
  # width == output logical width (2752), maximized-with-borders == 2724, so
  # >= 2740 cleanly separates the two. Non-browser focus: no-op.
  niriVideoMode = pkgs.writeShellScriptBin "niri-video-mode" ''
    #!/run/current-system/sw/bin/bash
    set -euo pipefail
    info=$(niri msg --json windows 2>/dev/null | jq -c '.[] | select(.is_focused)') || exit 0
    [ -n "$info" ] || exit 0
    app=$(jq -r '.app_id // empty' <<<"$info")
    title=$(jq -r '.title // empty' <<<"$info")
    width=$(jq -r '.layout.window_size[0] // 0' <<<"$info")
    case "$app" in
      zen*|*firefox*|chrom*|*brave*|*epiphany*) ;;
      *) exit 0 ;;
    esac
    [ "$title" = "Picture-in-Picture" ] && exit 0
    if [ "$width" -ge 2740 ]; then
      niri msg action fullscreen-window
      sleep 0.2
    fi
    niri msg action set-column-width 2048
    niri msg action center-column
  '';
in
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    # wf-recorder + slurp: screen recording wired to niri Ctrl+Shift+R
    environment.systemPackages = [ niriWrapped pkgs.wf-recorder pkgs.slurp niriVideoMode ];

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
