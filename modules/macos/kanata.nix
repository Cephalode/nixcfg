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
      caps ret
    )

    (deflayer main
      @hyc @hyr
    )

    (defalias
      ;; ── Meh keys ──────────────────────────────────────────────
      ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Cmd on hold)
      hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
      ;; Enter → Meh (Return on tap, Ctrl+Alt+Cmd on hold)
      hyr (tap-hold-press 200 200 ret (multi lctl lalt lmet))
    )
  '';

in
{
  # Use kanata-with-cmd (not plain kanata) — the default build disallows
  # the Cmd/Meta key which is essential for home row mods on macOS
  environment.systemPackages = with pkgs; [ kanata-with-cmd ];

  # Run kanata as a launchd agent so it starts at login and restarts on failure
  launchd.agents.kanata = {
    command = "${pkgs.kanata-with-cmd}/bin/kanata --cfg ${kanataConfig} --no-wait";
    path = [ pkgs.kanata-with-cmd ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/kanata.out.log";
      StandardErrorPath = "/tmp/kanata.err.log";
    };
  };
}
