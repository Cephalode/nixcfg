{ pkgs, lib, config, inputs, ... }:
let
  niriWrapped = inputs.wrappers.lib.evalPackage [
    ./module.nix
    { inherit pkgs; }
  ];

  # Borderless windowed fullscreen ("video mode") for the ultrawide:
  # toggles the focused browser between normal tiling and a floating
  # window sized to the exact 16:9 region of the 3440x1440@1.25 panel
  # (2048x1152 logical = 2560x1440 device px, x=352 centers it). Floating
  # windows ignore the 10px tiling gaps (verified live) and the zen
  # window-rule sets radius 0, so the app fills a flush borderless region
  # exactly like fullscreen — while niri keeps it a normal window and the
  # side windows stay visible. Non-browser focus: no-op.
  niriVideoMode = pkgs.writeShellScriptBin "niri-video-mode" ''
    #!/run/current-system/sw/bin/bash
    set -euo pipefail

    VID_W=2048
    VID_H=1152
    VID_X=352

    info=$(niri msg --json windows 2>/dev/null | jq -c '.[] | select(.is_focused)') || exit 0
    [ -n "$info" ] || exit 0
    app=$(jq -r '.app_id // empty' <<<"$info")
    title=$(jq -r '.title // empty' <<<"$info")
    win_id=$(jq -r '.id' <<<"$info")
    fl=$(jq -r '.is_floating' <<<"$info")
    width=$(jq -r '.layout.window_size[0] // 0' <<<"$info")

    case "$app" in
      zen*|*firefox*|chrom*|*brave*|*epiphany*) ;;
      *) exit 0 ;;
    esac
    [ "$title" = "Picture-in-Picture" ] && exit 0

    # Already in video mode (floating at ~video width) -> back to tiling.
    if [ "$fl" = "true" ] && [ "$width" -ge 2040 ] 2>/dev/null; then
      niri msg action toggle-window-floating --id "$win_id"
      niri msg action center-column --id "$win_id" 2>/dev/null || true
      exit 0
    fi

    # True-fullscreen -> leave it first so the window can be reshaped.
    if [ "$width" -ge 2740 ]; then
      niri msg action fullscreen-window --id "$win_id"
      sleep 0.2
    fi

    # Video mode ON: float, exact size, exact centered position.
    niri msg action toggle-window-floating --id "$win_id"
    sleep 0.15
    niri msg action set-window-width  --id "$win_id" "$VID_W"
    niri msg action set-window-height --id "$win_id" "$VID_H"
    niri msg action move-floating-window --id "$win_id" --x "$VID_X" --y 0
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
