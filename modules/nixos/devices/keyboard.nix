# modules/nixos/devices/keyboard.nix
#
# Kanata key remapper for NixOS
# Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)

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
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps esc tab
          )

          (deflayer main
            @hyc grv @cmt
          )

          (defalias
            ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)
            hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
            ;; Tab → Ctrl+Meta (Tab on tap, Ctrl+Super on hold)
            cmt (tap-hold-press 200 200 tab (multi lctl lmet))
          )
        '';
      };
    };
  };
}
