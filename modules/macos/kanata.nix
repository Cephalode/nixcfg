# modules/macos/kanata.nix
#
# Kanata key remapper for macOS — Unified Keybind Scheme
#
# Modifier roles:
#   Meh (Caps/Enter hold)  → Window management (aerospace)
#   Hyper (Meh + Shift)     → Window management extended (aerospace)
#   Meta/Cmd                → System commands (copy, paste, close, etc.)
#   Alt/Option              → Navigation (word movement, etc.)
#   Ctrl                    → Workspace switching/moving
#   Meta+Ctrl               → System control & services (boilerplate — TODO)
#   Meta+Alt                → Text manipulation & input (boilerplate — TODO)
#   Ctrl+Alt                → Environment & layout presets (boilerplate — TODO)
#
# IMPORTANT: After first deployment, you must manually grant Accessibility
# and Input Monitoring permissions in System Preferences → Privacy & Security
# for the kanata binary. Also ensure Caps Lock is NOT remapped in
# System Preferences → Keyboard → Modifier Keys.

{ config, pkgs, lib, ... }:

let
  kanataConfig = pkgs.writeText "kanata.kbd" ''
    ;; ──────────────────────────────────────────────────────────────
    ;; Unified Keybind Scheme for macOS
    ;; Mirrors the NixOS config in modules/nixos/devices/keyboard.nix
    ;; ──────────────────────────────────────────────────────────────
    ;;
    ;; Modifier roles:
    ;;   Meh (Caps/Enter hold)  → Window management (aerospace)
    ;;   Hyper (Meh + Shift)    → Window management extended (aerospace)
    ;;   Meta/Cmd               → System commands (copy, paste, close, etc.)
    ;;   Alt/Option             → Navigation (word movement, etc.)
    ;;   Ctrl                   → Workspace switching/moving

    (defcfg
      process-unmapped-keys yes
      ;; Exclude the karabiner virtual keyboard to prevent infinite loops
      macos-dev-names-exclude (
        "Karabiner DriverKit VirtualHIDKeyboard"
      )
      ;; Uncomment and add your keyboard device names to only intercept
      ;; specific keyboards. Run `kanata --list` to see device names.
      ;; macos-dev-names-include (
      ;;   "Your Keyboard Name Here"
      ;; )
    )

    (defsrc
      caps ret esc tab
      rmet
      h j k l
    )

    (deflayer main
      @hyc @hyr grv @cmt
      @rarr
      h j k l
    )

    ;; Right-Cmd held → HJKL become arrows. Other held modifiers (Shift,
    ;; etc.) pass through, so Shift+rcmd+h = shift+left.
    (deflayer rcarr
      _ _ _ _
      _
      left down up right
    )

    (defalias
      ;; ── Meh keys ──────────────────────────────────────────────
      ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Cmd on hold)
      hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
      ;; Enter → Meh (Return on tap, Ctrl+Alt+Cmd on hold)
      hyr (tap-hold-press 200 200 ret (multi lctl lalt lmet))
      ;; ── Ctrl+Meta keys ────────────────────────────────────────
      ;; Tab → Ctrl+Meta (Tab on tap, Ctrl+Cmd on hold)
      cmt (tap-hold-press 200 200 tab (multi lctl lmet))
      ;; ── Right-Cmd arrows ──────────────────────────────────────
      rarr (layer-while-held rcarr)
    )
  '';

  # Boot-order fix: at boot, BTM re-registers Karabiner's Core-Service
  # engine, which EXCLUSIVELY GRABS the keyboards; kanata then crash-loops
  # ("another process is already grabbing your keyboard exclusively") and
  # launchd throttles it to death. A plain RunAtLoad one-shot races the
  # engine's registration and always loses. Instead: WAIT for the engine
  # service to appear, boot it out, then kick kanata so it grabs cleanly.
  retireEngine = pkgs.writeShellScript "retire-karabiner-engine" ''
    echo "$(date) retire-karabiner-engine: waiting for Karabiner engine to register..."
    for i in $(seq 1 60); do
      if /bin/launchctl print system/org.pqrs.service.daemon.Karabiner-Core-Service >/dev/null 2>&1; then
        break
      fi
      /bin/sleep 2
    done
    /bin/launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
    /bin/launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
    echo "$(date) retire-karabiner-engine: engine booted out, kicking kanata"
    /bin/launchctl kick -k system/org.nixos.kanata 2>/dev/null || true
  '';

in
{
  # Use kanata-with-cmd (not plain kanata) — the default build disallows
  # the Cmd/Meta key which is essential for home row mods on macOS
  environment.systemPackages = with pkgs; [ kanata-with-cmd ];

  # Run kanata as a ROOT launchd daemon (not a user agent): kanata's macOS
  # backend talks to Karabiner's virtual HID daemon over a root-only IPC
  # socket (/Library/Application Support/org.pqrs/tmp/rootonly/), so a user
  # agent crash-loops with "Permission denied". KeepAlive restarts on failure.
  launchd.daemons.kanata = {
    command = "${pkgs.kanata-with-cmd}/bin/kanata --cfg ${kanataConfig} --no-wait";
    path = [ pkgs.kanata-with-cmd ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/kanata.out.log";
      StandardErrorPath = "/tmp/kanata.err.log";
    };
  };

  # Karabiner's remapping engine must NOT hold the keyboards (kanata is the
  # remapper). Its VirtualHIDDevice driver + daemon STAY: they are kanata's
  # output backend. BTM re-registers the engine at each boot; this daemon
  # waits for that registration, boots the engine out, then kicks kanata.
  launchd.daemons.retire-karabiner-engine = {
    command = "${retireEngine}";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/retire-karabiner.log";
      StandardErrorPath = "/tmp/retire-karabiner.log";
    };
  };
}
