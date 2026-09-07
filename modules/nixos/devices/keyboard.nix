# modules/nixos/devices/keyboard.nix
#
# Kanata key remapper for NixOS
# Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)
# Ctrl ↔ Super swap: physical Super = Ctrl (system), physical Ctrl = Super (Mod)
# Physical Ctrl (the Mod key after the swap) + HJKL → arrow keys (bare arrows:
# the held Super is momentarily released around the tap so apps see a plain
# keypress; Shift+HJKL = shift+arrow select)

{ config, lib, pkgs, ... }:

{
  config = {
    boot.kernelModules = [ "uinput" ];
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    users.groups.uinput = { };

    systemd.services.kanata-internalKeyboard.serviceConfig = {
      SupplementaryGroups = [
        "input"
        "uinput"
      ];
    };

    services.kanata = {
      enable = true;
      keyboards.internalKeyboard = {
        # TCP server on localhost for layer switching (layer-watch.service).
        # The nixpkgs module relaxes its sandbox when port != null.
        port = 10051;
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps esc tab lctl lmet rmet rctl
            h j k l
          )

          (deflayer main
            @hyc grv @cmt @mod lctl lctl rmet
            h j k l
          )

          ;; Arrow layer: active while physical Ctrl is held (@mod — it
          ;; sends Super/Mod after the swap). HJKL emit bare arrows;
          ;; everything else falls through to main, so every other Mod
          ;; combo still works.
          (deflayer arrows
            _ _ _ _ _ _ _
            @arl @ard @aru @arr
          )

          ;; Pass-through layer: no remaps. Switched to by layer-watch
          ;; whenever a fullscreen window has focus (games choke on
          ;; tap-hold and remapped modifiers).
          (deflayer nofs
            caps esc tab lctl lmet rmet rctl
            h j k l
          )

          (defalias
            ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)
            hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
            ;; Tab → Ctrl+Meta (Tab on tap, Ctrl+Super on hold)
            cmt (tap-hold-press 200 200 tab (multi lctl lmet))
            ;; ── Ctrl ↔ Super swap + arrow layer ──────────────────────
            ;; Physical Super/Win → Ctrl (system commands: copy/paste).
            ;; Physical Ctrl → Super (niri Mod: workspaces, launcher)
            ;; and while held, switches to the arrows layer for HJKL.
            mod (multi lmet (layer-while-held arrows))
            ;; HJKL emit the full Meh chord: held lmet (physical Ctrl after
            ;; the swap) + lctl + lalt + arrow = niri focus binds already
            ;; live in the RUNNING config — no relogin needed.
            ;; Shift+HJKL lands on the Hyper move binds.
            arl (multi lctl lalt left)
            ard (multi lctl lalt down)
            aru (multi lctl lalt up)
            arr (multi lctl lalt right)
          )
        '';
      };
    };

    # Switch kanata to the `nofs` pass-through layer while a fullscreen
    # window has focus (size-equality heuristic via niri IPC — niri has no
    # is_fullscreen field). Runs as the user so it can reach niri's socket.
    systemd.user.services.layer-watch = {
      description = "Kanata pass-through layer watcher (fullscreen apps)";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 ${./layer-watch.py}";
        Restart = "on-failure";
        RestartSec = 3;
      };
      # mkForce: systemd user units get a store-PATH default that would
      # otherwise conflict. Needs `niri` (system sw) on PATH.
      environment.PATH = lib.mkForce "/run/current-system/sw/bin";
    };
  };
}
