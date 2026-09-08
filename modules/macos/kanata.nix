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

    ;; Right-Cmd held → HJKL become arrows (ported from the old Karabiner
    ;; rule before its engine was disabled). Other held modifiers (Shift,
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

  # Retire Karabiner's modifier engine (Core-Service) — it exclusively
  # grabs the keyboards and starves kanata. Its VirtualHIDDevice driver +
  # daemon STAY: they are kanata's output backend. BTM re-registers the
  # engine at each boot, so this one-shot daemon bootouts it again; kanata
  # (KeepAlive) recovers as soon as the bootout lands.
  launchd.daemons.retire-karabiner-engine = {
    command = pkgs.writeShellScript "retire-karabiner-engine" ''
      /bin/launchctl bootout system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
      /bin/launchctl disable system/org.pqrs.service.daemon.Karabiner-Core-Service 2>/dev/null || true
      echo "$(date) retire-karabiner-engine ran" >> /tmp/retire-karabiner.log
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardErrorPath = "/tmp/retire-karabiner.log";
    };
  };
}
