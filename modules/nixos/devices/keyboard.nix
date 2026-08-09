# modules/nixos/devices/keyboard.nix
#
# Kanata key remapper for NixOS
# Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)

{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.kanata;
in
{
  options.hardware.kanata.devices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "List of device paths for kanata to intercept.";
  };

  config = lib.mkIf (cfg.devices != []) {
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
          devices = cfg.devices;
          extraDefCfg = "process-unmapped-keys yes";
          config = ''
            (defsrc
              caps
            )

            (deflayer main
              @hyc
            )

            (defalias
              ;; Caps Lock → Meh (Esc on tap, Ctrl+Alt+Super on hold)
              hyc (tap-hold-press 200 200 esc (multi lctl lalt lmet))
            )
          '';
        };
      };
    };
  };
}
