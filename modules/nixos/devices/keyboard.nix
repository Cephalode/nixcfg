# modules/nixos/devices/keyboard.nix
#
# Kanata key remapper for NixOS — Unified Keybind Scheme
#
# Modifier roles (unified across Linux, macOS, Windows):
#   Meh (Caps/Enter hold)  → Window management (niri / aerospace)
#   Hyper (Meh + Shift)     → Window management extended
#   Meta/Cmd               → System commands (copy, paste, close, etc.)
#   Alt/Opt                → Navigation (word movement, etc.)
#   Ctrl                   → Workspace switching/moving
#   Meta+Ctrl              → System control & services (boilerplate — TODO)
#   Meta+Alt               → Text manipulation & input (boilerplate — TODO)
#   Ctrl+Alt               → Environment & layout presets (boilerplate — TODO)
#
# On Linux, system commands use Ctrl (not Cmd/Meta), so we SWAP Ctrl and
# Super at the keyboard level. This means:
#   Physical Ctrl key  → sends Super  → triggers niri Mod binds (workspace)
#   Physical Super key → sends Ctrl   → triggers system commands (copy, etc.)
#
# Home row mods (when enabled in main layer):
#   Left:  a→Super  s→Alt  d→Shift  f→Ctrl
#   Right: j→Ctrl   k→Shift  l→Alt  ;→Super
#
# Compare to macOS (where system commands use Cmd/Meta instead of Ctrl):
#   Left:  a→Ctrl  s→Alt  d→Shift  f→Cmd/Meta
#   Right: j→Cmd/Meta  k→Shift  l→Alt  ;→Ctrl
#
# The RESULT is the same muscle memory: hold the same finger position
# for the same role on both platforms.
#
# Toggle home row mods:
#   Hold \, then press 1 to enable (main layer)
#   Hold \, then press 2 to disable (base layer)

{ pkgs, ... }:
{
  # Enable the uinput module
  boot.kernelModules = [ "uinput" ];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = { };

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    wlr-which-key
  ];

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.2:1.0-event-kbd" # Main keyboard (event0)
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:9.3:1.1-event-kbd" # Numpad? (event6)
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          ;; ──────────────────────────────────────────────────────────────
          ;; Unified Keybind Scheme for NixOS
          ;; Mirrors the macOS config in modules/macos/kanata.nix
          ;; ──────────────────────────────────────────────────────────────
          ;;
          ;; Modifier roles (unified across all platforms):
          ;;   Meh (Caps/Enter hold)  → Window management (niri)
          ;;   Hyper (Meh + Shift)     → Window management extended
          ;;   Meta/Cmd               → System commands (copy, paste, close, etc.)
          ;;   Alt/Opt                → Navigation (word movement, etc.)
          ;;   Ctrl                   → Workspace switching/moving
          ;;
          ;; On Linux, system commands use Ctrl (not Cmd/Meta), so we SWAP
          ;; Ctrl and Super at the keyboard level:
          ;;   Physical Ctrl  → sends Super → workspace (niri Mod)
          ;;   Physical Super → sends Ctrl  → system commands (copy, etc.)
          ;;
          ;; This gives the same muscle memory as macOS:
          ;;   Thumb/webbling position → system commands on both platforms
          ;;   Pinky position          → workspace switching on both platforms
          ;;
          ;; Home row mods (when enabled in main layer):
          ;;   Left:  a→Super  s→Alt  d→Shift  f→Ctrl
          ;;   Right: j→Ctrl   k→Shift  l→Alt  ;→Super
          ;;
          ;; Toggle home row mods:
          ;;   Hold \, then press 1 to enable (main layer)
          ;;   Hold \, then press 2 to disable (base layer)

          (defsrc
                 1    2
            caps a    s    d    f    j    k    l    ;    ret  \
            lctl lmet rmet rctl
          )

          (deflayer main
                 _    _
            @hyc @aM  @sA  @dS  @fC  @jC  @kS  @lA  @;M  @hyr @lay
            lmet lctl lctl rmet
          )

          (deflayer base
                 _    _
            _    _    _    _    _    _    _    _    _    _    _
            lmet lctl lctl rmet
          )

          (deflayer switch
                 @l1  @l2
            _    _    _    _    _    _    _    _    _    _    _
            lmet lctl lctl rmet
          )

          (defalias
            ;; ── Meh keys ──────────────────────────────────────────────
            ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)
            hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
            ;; Enter → Meh (Return on tap, Ctrl+Alt+Super on hold)
            hyr (tap-hold-press 200 200 ret (multi lctl lalt lmet))

            ;; ── Home row mods (left side) ─────────────────────────────
            ;; Swapped vs macOS: f→Ctrl (system), a→Super (workspace)
            aM  (tap-hold       200 200 a   lmet)   ;; a → Super (workspace / niri Mod)
            sA  (tap-hold       200 200 s   lalt)   ;; s → Alt (navigation)
            dS  (tap-hold       200 200 d   lsft)   ;; d → Shift
            fC  (tap-hold       200 200 f   lctl)   ;; f → Ctrl (system commands)

            ;; ── Home row mods (right side) ────────────────────────────
            ;; Swapped vs macOS: j→Ctrl (system), ;→Super (workspace)
            jC  (tap-hold       200 200 j   rctl)   ;; j → Ctrl (system commands)
            kS  (tap-hold       200 200 k   rsft)   ;; k → Shift
            lA  (tap-hold       200 200 l   ralt)   ;; l → Alt (navigation)
            ;M  (tap-hold       200 200 ;   rmet)   ;; ; → Super (workspace / niri Mod)

            ;; ── Layer switching ───────────────────────────────────────
            lay (layer-while-held switch)
            l1  (layer-switch main)     ;; Enable home row mods
            l2  (layer-switch base)     ;; Disable home row mods
          )
        '';
      };
    };
  };
}
